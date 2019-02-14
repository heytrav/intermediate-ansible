## Set theory


#### Set theory in Ansible

```
$ cd $WORKDIR/set-theory
.
├── inventory
│   └── hosts
├── group-set-theory.yml
└── set-filters.yml
```


#### Set theory tools

* Ansible provides a few useful filters for working with sets of data
* union
  - union of two lists
* intersect
  - unique list of items in two lists
* difference
  - list of items in list 1 but not in list 2


#### Using set theory filters

* Have a look at `set-filters.yml`
* Demonstrates a few simple set operations
* Run the playbook

  ```
  $ ansible-playbook set-filters.yml
  ```


#### Set theory using groups

* It is possible to apply set theory to inventory items as well
* The _hosts_ attribute has syntax for set theory operations on inventory 
* These enable fine control over which hosts playbooks operate
* Run the playbook `group-set-theory.yml`
  ```
  $ ansible-playbook -i inventory/hosts \
      group-set-theory.yml
  ```


#### Union

Combination of hosts in two groups

![union](img/union.svg "Union") <!-- .element: width="20%" height="20%" -->

All hosts in<!-- .element: class="fragment" data-fragment-index="0" --> _web_ and _db_ groups 

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: Union of hosts
  <mark>hosts: web:db</mark>
  gather_facts: false
  tasks:
</code></pre>



#### Intersection

Hosts that are in first and second group

![Intersect](img/intersect.svg "Intersection") <!-- .element: width="20%"
height="20%" -->

Hosts that are in both the<!-- .element: class="fragment" data-fragment-index="0" --> _web_ and the _blue_ group 

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: Intersection of hosts
  <mark>hosts: web:&blue</mark>
  gather_facts: false
  tasks:
</code></pre>


#### Difference

Set of hosts in first set but not in second set

![Difference](img/difference.svg "Difference")<!-- .element: width="20%"
height="20%" -->

Hosts that are in the<!-- .element: class="fragment" data-fragment-index="0" --> _wellington_ group **but not in the _blue_** group

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: Difference of groups
  <mark>hosts: wellington:!blue</mark>
  gather_facts: false
  tasks:
</code></pre>


#### Summary

* Ansible provides tools for manipulating sets of items
* Set theory filters can be used for working on lists
* Set theory operators can also be applied to inventory items when running
  playbooks
* Enable fine tuning of operations in playbooks


#### Tearing down our project

```
$ ansible-playbook -i inventory \
    -K --ask-vault-pass  -e prefix=$(hostname) \
        remove-hosts.yml
```

* The  `remove-hosts.yml` playbook
  - Shutdown openstack instances <!-- .element: class="fragment" data-fragment-index="0" -->
  - Deletes private network <!-- .element: class="fragment" data-fragment-index="1" -->
  - Removes security groups <!-- .element: class="fragment" data-fragment-index="2" -->
  - Removes local entries from both<!-- .element: class="fragment" data-fragment-index="3" --> `/etc/hosts` and `~/.ssh/config` 
