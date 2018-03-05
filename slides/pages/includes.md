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

* Have a look at `ansible/long-playbook.yml`
* It contains a few tasks for
    * Installing some monitoring libraries
    * Installing and setting up a database
    * Setting up a folder for a project
* Works fine, but managing a few unrelated jobs
* Let's try splitting these up into components


## Including files in Ansible

#### `include`

![Deprecated](img/3678.deprecated.png "Deprecated") <!-- .element: class="fragment" data-fragment-index="0" -->



## Including files in Ansible

#### `include_tasks`

* Dynamically include a task list


```
tasks:
- debug:
    msg: Task in main playbook

- include_tasks: tasks/some-stuff.yml

- debug:
    msg: Second task in main playbook
```



