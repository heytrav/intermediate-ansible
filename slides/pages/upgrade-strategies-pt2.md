# Upgrade strategies

## Expand and contract


###  Expand and contract upgrades

```
$ cd $WORKDIR/lesson7
.
└── ansible
    ├── add-hosts-to-inventory.yml
    ├── check-defined.yml
    ├── deploy.yml
    ├── expand-update.yml
    ├── files
    │   ├── mycluster_rsa.pub
    │   └── rsyslog-haproxy.conf
    ├── group_vars
```


### Expand and contract

* This strategy involves deploying updates on completely new hosts
* Advantages
  - Machines are more up-to-date
  - No need to worry about config not managed by Ansible
  - Avoid configuration drift
  - Rolling back much easier


### Upgrading by expanding contract

![cluster-pre-upgrade](img/expand-contract-pre-upgrade.svg "Pre upgrade")


### Expand phase

![cluster-upgrade-step1](img/expand-contract-upgrade.svg "During upgrade") <!-- .element height="50%" width="50%" -->

* Deploy application update to new machines <!-- .element: class="fragment" data-fragment-index="0" -->
* Current version remains active <!-- .element: class="fragment" data-fragment-index="1" -->


### Change to new cluster

![cluster-upgrade-step2](img/expand-contract-upgrade-2.svg "Post upgrade")<!-- .element height="40%" width="40%" -->

* Once new cluster finished and healthy: <!-- .element: class="fragment" data-fragment-index="0" -->
  - Change DNS to point at new cluster
  - Stop services on old cluster
* Decommision old cluster <!-- .element: class="fragment" data-fragment-index="1" -->


### Managing inventory

* The expand approach requires dynamic naming of hosts <!-- .element: class="fragment" data-fragment-index="0" -->
* Naming scheme might use application version combined with some other <!-- .element: class="fragment" data-fragment-index="1" -->
  identifier
  - `web-v1-1`
  - `web-v1-2`
  - `app-v1-1`
* Our traditional static inventory file not sufficient <!-- .element: class="fragment" data-fragment-index="2" -->
* Need to use dynamic inventory <!-- .element: class="fragment" data-fragment-index="3" -->


### Dynamic inventory scripts

* Executable script <!-- .element: class="fragment" data-fragment-index="0" -->
* Interact with  <!-- .element: class="fragment" data-fragment-index="1" -->
  * Database <!-- .element: class="fragment" data-fragment-index="2" -->
  * Cloud host API <!-- .element: class="fragment" data-fragment-index="3" -->
* Must support two command line flags <!-- .element: class="fragment" data-fragment-index="4" -->
  * `--host=<hostname>` 
  * `--list`


### Dynamic inventory interface

#### `--list` option

List all groups and details of hosts <!-- .element: class="fragment" data-fragment-index="0" -->
<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
$ ./dynamic-inventory.py --list
{"web": ["training-web1", "training-web2"],
 "app": ["training-app1", "training-app2"],
 "db": ["training-db1"]
 .
 "_meta": {
    "hostvars": {
        "training-web1": {
    }
 }

</code></pre>


### Dynamic inventory interface

#### `--host=<hostname>` option

Fetch details for a particular host

```
$ ./dynamic-inventory.py --host=training-db1
{ "ansible_host": "192.168.99.101", 
   "ansible_distribution": "Ubuntu",
.
.

```


### Using dynamic inventories

* Ansible will run<!-- .element: class="fragment" data-fragment-index="0" --> _executable_ files in inventory path 
  * Configured in `ansible.cfg`
  * Passed to command line option `-i`
  <pre class="fragment" data-fragment-index="1" ><code data-trim data-noescape>
  $ ansible-playbook -i <mark>ansible/inventory</mark> \ 
              ansible/playbook.yml
  </code></pre>
* File or directory of files <!-- .element: class="fragment" data-fragment-index="2" -->


