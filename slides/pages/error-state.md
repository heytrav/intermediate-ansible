# Task conditions



# Task conditions

```
$ cd $WORKDIR/lesson2
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
<asciinema-player loop="1" cols="100" theme="solarized-light" start-at="13.0" rows="15" autoplay="1" src="asciinema/error-playbook.cast"></asciinema-player>


## Ignore errors

#### `ignore_errors`

Tell Ansible to continue execution when an error happens

```
    - name: Delete a branch from repository
      command: git branch -D notabranch
```


## Error state

* Modules generally know how to interpret task error



## Defining failed state

#### `failed_when`

* Define when ansible should interpret a task has failed
* Similar to _when_ usage
* Use with _register_ to capture stdout/stderr


## Command errors

In `project.yml`:
```
    - name: Add images to new table
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "INSERT INTO images (image) VALUES ('{{ item }}')" {{ database }}
      with_items: "{{ images }}"
```
* Can be run once
* Following attempts trigger error due to unique constraint
* Only really consider failed when:
  - result code is 1 AND
  - not a duplicate error


### Exercise: Allow task to pass on duplicate errors

* Use _register_ to capture stdout/stderr

<pre class="fragment" data-fragment-index="0"><code data-noescape data-trim >
    - name: Add images to new table
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "INSERT INTO images (image) VALUES ('{{ item }}')" {{ database }}
      with_items: "{{ images }}"
      <mark class="fragment" data-fragment-index="1">register: db_insert</mark>
      <mark class="fragment" data-fragment-index="2">failed_when: db_insert.rc != 0 and 'duplicate' not in db_insert.stderr</mark>

</code></pre>

* rerun the playbook <!-- .element: class="fragment" data-fragment-index="3" -->


## Defining changed state

```
    - name: Create table for pics 
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "CREATE TABLE IF NOT EXISTS images (id SERIAL primary key not null,
        image char(200) not null unique)" {{ database }}
```
* Table only created on first run
* Task always registers as _changed_



## Changed state

#### `changed_when`







