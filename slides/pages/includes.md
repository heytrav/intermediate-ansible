# Organising Infrastructure Code


### Organising Infrastructure Code

```
$ cd $WORKDIR/sample-code/lesson1
$ tree
.
└── ansible
    └── playbook.yml
```

>In all following examples, `$WORKDIR` is the path to the `sample-code` directory.


### Refactoring Infrastructure Code

* Projects often grow organically <!-- .element: class="fragment" data-fragment-index="0" -->
* Pressure to get things done quickly <!-- .element: class="fragment" data-fragment-index="1" -->
* Decisions that "seemed like a good idea at the time" evolve into technical debt <!-- .element: class="fragment" data-fragment-index="2" -->
    * Copy paste <!-- .element: class="fragment" data-fragment-index="2" -->
    * Code organisation <!-- .element: class="fragment" data-fragment-index="3" -->
* Eventually you will probably need to refactor <!-- .element: class="fragment" data-fragment-index="4" -->


### Refactoring a Playbook

* Ideal to break playbook into smaller components
  - Compartmentalise logic
  - Avoid repetition
* Use Ansible _includes_
  - `include`
  - `import_tasks`
  - `include_tasks`



### Refactoring a long playbook

![Long playbook](img/playbook-long.svg "Long playbook")

* Goal is to restructure so that
  - Related tasks are grouped together <!-- .element: class="fragment" data-fragment-index="0" -->
  - Components can be reused if possible <!-- .element: class="fragment" data-fragment-index="1" -->


### Task files

* The conventional approach is to break tasks out into separate "task files" <!-- .element: class="fragment" data-fragment-index="0" -->
* Task file only contains a YAML list <!-- .element: class="fragment" data-fragment-index="1" -->
<pre class="fragment" data-fragment-index="1"><code data-trim>
    - name: This is task 1

    - name: This is task 2
    .
    .
    - name: This is task n
</code></pre>
* Ideally tasks related to specific purpose <!-- .element: class="fragment" data-fragment-index="2" -->
* Import them into your playbooks as needed <!-- .element: class="fragment" data-fragment-index="3" -->



### Refactored playbook

![Broken up playbook](img/playbook-refactor1.svg "Refactored")


### Project layout

Conventional organisation of tasks in ansible
 <pre><code data-trim data-noescape>
 $ mkdir -p $WORKDIR/lesson1/ansible/tasks
 .
 └── ansible
      ├── hosts
      ├── long-playbook.yml
<mark class="fragment" data-fragment-index="0">      └── tasks</mark>
<mark class="fragment" data-fragment-index="1">            ├── db.yml
            ├── monitoring.yml
            ├── server.yml
            └── setup.yml</mark>
 </code></pre>

* In general you can put task files anywhere as long they're resolvable by ansible <!-- .element: class="fragment" data-fragment-index="2" -->
* Having moved tasks out of playbook, you now need a way to import them <!-- .element: class="fragment" data-fragment-index="3" -->



### Including files in Ansible

#### `include`

![Deprecated](img/3678.deprecated.png "Deprecated") <!-- .element: class="fragment" data-fragment-index="0" -->



### Including files in Ansible

#### `import_tasks`

Statically include a task list

```yaml
name: Main playbook
tasks:
  - debug:
      msg: Task in main playbook

  - import_tasks: "tasks/import-stuff.yml"

  - debug:
      msg: Second task in main playbook
```


### Including files in Ansible

#### `include_tasks`

* Dynamically include a task list

```yaml
name: Main playbook
tasks:
  - debug:
      msg: Task in main playbook

  - include_tasks: tasks/import-stuff.yml
  - include_tasks: "tasks/{{ myfile  }}.yml"

  - debug:
      msg: Second task in main playbook
```


### Exercise: Refactor a playbook using task files

* Break up `long-playbook.yml` into separate tasks files by _function_
  - basic setup
  - db setup
  - application setup
  - monitoring setup


### Refactoring our playbook

```yaml
  tasks:
    - debug:
        msg: Running main playbook task

    - import_tasks: tasks/basic.yml
    - import_tasks: tasks/db.yml
    - import_tasks: tasks/app.yml
    - import_tasks: tasks/monitoring.yml
    
```
Answers may vary <!-- .element: class="fragment" data-fragment-index="0" -->


### Refactoring our playbook

#### Alternative approach

* Use `include_tasks` to dynamically load files

```yaml
  tasks:
    - debug:
        msg: Running main playbook task

    - include_tasks: "tasks/{{ item }}.yml"
      with_items:
        - basic
        - db
        - app
        - monitoring
```
note: import_tasks will not work here because of how ansible parses playbooks <!-- .element: class="fragment" data-fragment-index="0" -->



### Passing variables to includes

* Importing tasks is useful when it is necessary to iterate over sets of tasks
* ..or when tasks need to be run in different contexts 
* Can be necessary to pass variables into included/imported tasks


### Passing variables to includes

* Pass a variable to an include using `vars:` attribute
* Variable scope only within the included task file

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
 - import_tasks: tasks/some-tasks.yml
   vars:
     foo: "bar"
     bizz: "buzz"
</code></pre>


### Exercise: Refactor a playbook to use tasks

* Playbook `touch-files.yml` just creates a directory and touches a few files
* Refactor this to use tasks instead



### Exercise: pass variables to an included file

* Task file 
  - Use variables instead of fixed paths

<pre  class="fragment" data-fragment-index="0"><code data-trim>
$ mkdir -p tasks
$ $EDITOR tasks/files.yml
</code></pre>

<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
- name: Create directory for file
  file:
    path: "{{ path }}"
    state: directory

- name: touch file in directory
  file:
    path: "{{ path }}/{{ file }}"
    state: touch 
</code></pre>


### Exercise: pass variable to an included file

* Modify `touch-files.yml` to use `tasks/files.yml`
* Pass the path and file parameters in to tasks

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
  tasks:
    
    - import_tasks: tasks/files.yml
      vars:
        path: /tmp/foo
        file: bar.txt

    - import_tasks: tasks/files.yml
      vars:
        path: /tmp/foo
        file: bizz.txt
</code></pre>


### Refactor main playbook to pass dictionary to include

* This works, but we import the same task multiple times for different files
* It is possible to use complex data in our tasks so we only have to import
  the task file once

<pre  class="fragment" data-fragment-index="0"><code data-trim>
- name: Create a directory and touch file
  import_tasks: tasks/files.yml
  vars:
    files:
      foo:
        path: /tmp/foo
      bar:
        path: /tmp/foo
</code></pre>


### Iterating over complex data

* Modify `files.yml` to process _files_ dictionary

```yaml
- name: Create directory
  file:
    path: "{{ item.value.path }}"
    state: directory
  with_dict:  "{{ files }}"

- name: touch file
  file:
    path: "{{ item.value.path }}/{{ item.key }}"
    state: touch
  with_dict:  "{{ files }}"

```



### Passing conditionals to included files

* Includes can also take a conditional "when" attribute <!-- .element: class="fragment" data-fragment-index="0" -->
    <pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
   - import_tasks: some-stuff.yml
     <mark>when: true</mark>
    </code></pre>
* Conditional is not used to control import <!-- .element: class="fragment" data-fragment-index="1" -->
* Rather it is applied to each task in the imported file <!-- .element: class="fragment" data-fragment-index="2" -->



### Passing conditionals

* Let's add a conditional to import_tasks in `long-playbook.yml`

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - import_tasks: tasks/basic.yml
      vars:
        some_list:
          - true
          - false
      when: item | bool <mark  class="fragment" data-fragment-index="1">&lt;-- condition gets passed to each task</mark>
</code></pre>
 


### Conditional behaviour on imported tasks

* Modify `tasks/basic.yml` to iterate over the `some_list` variable
* Run `long-playbook.yml` and note some tasks are skipped when `item == false`

```yaml
- name: Basic setup task
  debug:
    msg: Running 1st setup task
  with_items: "{{ some_list }}"

- name: Basic setup task 2
  debug:
    msg: Running 2nd setup task
  with_items: "{{ some_list }}"
```


### Summary

* Includes provide way to organise infrastructure for large projects
  - `import_tasks` for static inclusion
  - `include_tasks` for dynamic inclusion
* Include statements take a `vars` argument for passing variable data in scope
  of include
* Conditionals applied to includes are actually applied to each task in an
  included file
