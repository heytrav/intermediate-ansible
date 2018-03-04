# Organising Ansible


## Refactoring Infrastructure Code

* Projects often grow organically <!-- .element: class="fragment" data-fragment-index="0" -->
* Pressure to get things done quickly eventually become technical debt <!-- .element: class="fragment" data-fragment-index="1" -->
    * Copy paste <!-- .element: class="fragment" data-fragment-index="2" -->
    * Code organisation <!-- .element: class="fragment" data-fragment-index="3" -->
* Eventually you will probably need to refactor <!-- .element: class="fragment" data-fragment-index="4" -->


## Compartmentalising Ansible

    $ cd $WORKDIR/sample-code/lesson1
    $ tree
    .
    └── ansible
        └── playbook.yml
