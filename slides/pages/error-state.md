# Task conditions



# Task conditions

```
$ cd $WORKDIR/lesson3
```


## Managing task conditions

* Most modules have their own way of defining failure or change of state <!-- .element: class="fragment" data-fragment-index="0" -->
* Some improvise based on return code <!-- .element: class="fragment" data-fragment-index="1" -->
  - command family of modules: (command, shell, script, raw)
* Shell commands typically return uninformative error codes <!-- .element: class="fragment" data-fragment-index="2" -->
  - 0 for success
  - &ge; 1 for failure
* May be necessary to override Ansible behaviour <!-- .element: class="fragment" data-fragment-index="3" -->


## Managing errors

#### `ansible/runtools.yml`

* This playbook tries to:
  - Delete a branch from the repository
  - Run a script which creates a directory
* Run playbook `ansible/runtools.yml`
<asciinema-player loop="1" cols="70" theme="solarized-light" start-at="13.0" rows="10" autoplay="1" font-size="medium" src="asciinema/error-playbook.cast"></asciinema-player>


## Ignore errors

#### `ignore_errors`

* Tell Ansible to continue execution when an error happens
* Accepts a boolean: `true`, `yes`
<pre><code data-trim data-noescape>
    - name: Delete a branch from repository
      command: do_something_that_fails.sh
      <mark class="fragment" data-fragment-index="0">ignore_errors: true</mark>

</code></pre>


### Exercise: Ignore errors from a task

* In `ansible/runtools.yml`
* First task fails to delete a branch that does not exist
* Not a critical error for our playbook
* Alter the first task in `runtools.yml` so errors are ignored
<pre class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Delete a branch from repository
      command: git branch -D notabranch
      ignore_errors: true
</code></pre>


### Problems with `ignore_errors`

* Blunt way of bypassing errors
* Output of task can be confusing because it looks like something bad happened
* May miss failures that are important
* Shell command output may not be failure


### Controlling failure

* Run `ansible/runtools.yml` a couple times
* The second task in `ansible/runtools.yml` 
  - runs a script `tools.sh` 
    * creates a directory
    * fails if directory already exists
* Actually failing because of idempotent behaviour


### Preventing failure

#### How do we keep playbook from failing?

* One option would be to check if directory exists before running script
<pre><code data-trim data-noescape>
    - name: Get status of testdir
      stat:
        path: "{{ application_directory }}/testdir"
      register: stat_output

    - name: Run tools command in working directory
      shell: "{{ application_directory }}/tools.sh"
      args:
        chdir: "{{ application_directory }}"
      <mark>when: not stat_output.stat.exists</mark>
</code></pre>
* Naive approach that adds extra tasks


## Defining failed state

#### `failed_when`

* A finer way of dealing with failed states
* Define when ansible should interpret a task has failed
* Semantically similar to _when_ (i.e. conditional)
* Use with _register_ to capture stdout/stderr
<pre class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Run some command
      shell: do_something_with_error_code.sh
<mark  class="fragment" data-fragment-index="1">    register: my_output
      failed_when: 
      - my_output.rc != 0
      - not my_output.stderr | search('not a fail!')</mark>
</code></pre>



### Exercise: Do not fail if directory exists

* Use `failed_when` to keep task from failing if directory exits
<pre  class="fragment" data-fragment-index="0"><code data-trim>
    - name: Run tools command in working directory
      shell: "{{ application_directory }}/tools.sh"
      args:
        chdir: "{{ application_directory }}"
      register: tools_output
      failed_when: 
        - tools_output.rc != 0
        - not tools_output.stderr | search('already exists')
</code></pre>
* Run playbook again <!-- .element: class="fragment" data-fragment-index="1" -->


### Defining _changed_ state

* The `ansible/runtools.yml` playbook still has a probem
* It always reports the task for running the script as _changed_


### Defining _changed_ state

#### `changed_when`

* `changed_when` attribute can be used to define criteria for _changed_
* Also similar semantics to _when_ conditional
<pre class="fragment" data-fragment-index="0"><code data-trim data-noescape>
  - name: Perform a task
    command: change_something.sh
    changed_when: &lt;condition true&gt;
</code></pre>


#### Exercise: Control task changed state

* Change task in `runtools.yml` to show changed when directory created

<pre class="fragment" data-fragment-index="0"><code data-trim>
    - name: Run tools command in working directory
      shell: "{{ application_directory }}/tools.sh"
      args:
        chdir: "{{ application_directory }}"
      register: tools_output
      failed_when: 
        - tools_output.rc != 0
        - not tools_output.stderr | search('already exists')
      changed_when:
        - tools_output.rc == 0
        - tools_output.stdout | search('Created testdir')
</code></pre>


###  _creates_ and _removes_ with command modules

*  _command_, _script_ and _shell_ all take a special attribute to influence
   behaviour
   - creates
   - removes
* These commands will check ahead of time whether or not a file/directory exists



### Examples of _creates_ and _removes_

* Task used to install reveal presentation on training machines

```
  - name: Set up reveal presentation
    command: npm install
    args:
      chdir: "{{ ansible_env.HOME }}/intermediate-ansible/slides"
      creates: node_modules

  - name: Remove some extra files
    command: rm -fr somedirectory
    args:
      removes: somedirectory

```


#### Exercise: modify task to use _creates_ argument

* Can replace `changed_when` clause

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Run tools command in working directory
      shell: "{{ application_directory }}/tools.sh"
      args:
        chdir: "{{ application_directory }}"
        <mark>creates: testdir</mark>
      register: tools_output
      failed_when: 
        - tools_output.rc != 0
        - not tools_output.stderr | search('already exists')
</code></pre>


#### Exercise: Add task to remove a directory

* Remove the `temporarydir` in lesson3
* Use _removes_ argument

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Directory created by script
      command: rm -fr temporarydir
      args:
        removes: temporarydir
        chdir: "{{ application_directory }}"
</code></pre>


### Applied control of task conditions

* `ansible/db.yml` creates a db table and adds some images
* There are a couple problems:
  - _Create table for pics_ task always displays changed
  - _Add images to new table_ will fail after first run due to unique constraint
* So let's apply `changed_when` and `failed_when` to fix



### Exercise: Allow task to pass on duplicate errors

* Use _register_ to capture stdout/stderr
* Do not fail if error response has the word "duplicate"

<pre class="fragment" data-fragment-index="0"><code data-noescape data-trim >
    - name: Add images to new table
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "INSERT INTO images (image) VALUES ('{{ item }}')" {{ database }}
      with_items: "{{ images }}"
      <mark class="fragment" data-fragment-index="1">register: db_insert</mark>
      <mark class="fragment" data-fragment-index="2">failed_when: 
        - db_insert.rc != 0 
        - not db_insert.stderr | search('duplicate')</mark>

</code></pre>



### Exercise: only show changed when table created

* First task doesn't fail because of _if not exists_ clause
* If a table exists postgres outputs _already exists, skipping_ to stderr

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Create table for pics 
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "CREATE TABLE IF NOT EXISTS images (id SERIAL primary key not null,
        image char(200) not null unique)" {{ database }}
<mark  class="fragment" data-fragment-index="1">      register: create_table_output
      changed_when:
        - create_table_output.rc == 0
        - not create_table_output.stderr | search('already exists')</mark>

</code></pre>



### Summary

* It is sometimes necessary to override or ignore Ansible task conditions
* Failed and changed states can be determined for arbitrary tasks using
  - `failed_when`
  - `changed_when`
* command modules also have _creates_ and _removes_ attributes to help take
  care of some of the work






