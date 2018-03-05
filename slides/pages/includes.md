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


## Long playbook

![Long playbook](img/playbook-long.svg "Long playbook")


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



## Including files in Ansible

#### `include`

![Deprecated](img/3678.deprecated.png "Deprecated") <!-- .element: class="fragment" data-fragment-index="0" -->



## Including files in Ansible

#### `import_tasks`

Statically include a task list

```

```


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



