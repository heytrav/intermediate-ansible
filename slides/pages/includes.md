# Organising Ansible


## Organising Ansible

```
$ cd $WORKDIR/sample-code/lesson1
$ tree
.
└── ansible
    └── playbook.yml
```

>In all following examples, `$WORKDIR` is the path to the `sample-code` directory.


## Refactoring Infrastructure Code

* Projects often grow organically <!-- .element: class="fragment" data-fragment-index="0" -->
* Pressure to get things done quickly eventually become technical debt <!-- .element: class="fragment" data-fragment-index="1" -->
    * Copy paste <!-- .element: class="fragment" data-fragment-index="2" -->
    * Code organisation <!-- .element: class="fragment" data-fragment-index="3" -->
* Eventually you will probably need to refactor <!-- .element: class="fragment" data-fragment-index="4" -->


## Refactoring a Playbook

* Ideal to break playbook into smaller components
  - Compartmentalise logic
  - Avoid repetition
* Use Ansible _includes_
  - `include`
  - `import_tasks`
  - `include_tasks`



## Long playbook

![Long playbook](img/playbook-long.svg "Long playbook")

* Goal is to restructure so that
  - Related tasks are grouped together
  - Components can be _reused_ if possible


## Refactored playbook

![Broken up playbook](img/playbook-refactor1.svg "Refactored")


## Project layout

Conventional organisation of tasks in ansible
 <pre><code data-trim data-noescape>
 $ mkdir -p $WORKDIR/lesson1/ansible/tasks
 .
 └── ansible
      ├── hosts
      ├── long-playbook.yml
      <mark>└── tasks
            ├── db.yml
            ├── monitoring.yml
            ├── server.yml
            └── setup.yml</mark>
 </code></pre>


## Task files

* Task file contains a YAML list
* Ideally tasks related to specific purpose

```yaml
---
- name: This is task 1

- name: This is task 2
.
.
- name: This is task n
```


## Including files in Ansible

#### `include`

![Deprecated](img/3678.deprecated.png "Deprecated") <!-- .element: class="fragment" data-fragment-index="0" -->



## Including files in Ansible

#### `import_tasks`

Statically include a task list

```yaml
tasks:
  - debug:
      msg: Task in main playbook

  - import_tasks: "tasks/import-stuff.yml"

  - debug:
      msg: Second task in main playbook
```


## Including files in Ansible

#### `include_tasks`

* Dynamically include a task list

```yaml
tasks:
  - debug:
      msg: Task in main playbook

  - include_tasks: tasks/import-stuff.yml
  - include_tasks: "tasks/{{ myfile  }}.yml"

  - debug:
      msg: Second task in main playbook
```



