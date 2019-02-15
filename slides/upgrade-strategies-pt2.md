## Upgrade strategies

### Expand and contract


####  Expand and contract upgrades

```
$ cd $WORKDIR/upgrade-strategies-2
.
├── add-hosts-to-inventory.yml
├── check-defined.yml
├── deploy.yml
├── expand-update.yml
├── files
│   ├── mycluster_rsa.pub
│   └── rsyslog-haproxy.conf
├── group_vars
```



#### Describing our cluster

* The expand approach requires dynamic naming of hosts <!-- .element: class="fragment" data-fragment-index="0" -->
* Server names based on application version <!-- .element: class="fragment" data-fragment-index="1" -->
  identifier
  - `web-v1-1`
  - `web-v1-2`
  - `app-v1-1`
* Traditional static inventory file not practical <!-- .element: class="fragment" data-fragment-index="2" -->
* Need to use dynamic inventory <!-- .element: class="fragment" data-fragment-index="3" -->


#### Dynamic inventory scripts

* Executable script <!-- .element: class="fragment" data-fragment-index="0" -->
* Interacts with  <!-- .element: class="fragment" data-fragment-index="1" -->
  * LDAP <!-- .element: class="fragment" data-fragment-index="2" -->
  * Database <!-- .element: class="fragment" data-fragment-index="3" -->
  * Cloud host API <!-- .element: class="fragment" data-fragment-index="4" -->
* Outputs JSON <!-- .element: class="fragment" data-fragment-index="5" -->
* Must support two command line flags <!-- .element: class="fragment" data-fragment-index="6" -->
  * `--host=<hostname>` 
  * `--list`


#### Dynamic inventory interface

##### `--list` option

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


#### Dynamic inventory interface

##### `--host=<hostname>` option

Fetch details for a particular host

```
$ ./dynamic-inventory.py --host=training-db1
{ "ansible_host": "192.168.99.101", 
   "ansible_distribution": "Ubuntu",
.
.

```


#### Using dynamic inventories

* Inventory can be a file or directory of files <!-- .element: class="fragment" data-fragment-index="0" -->
* Ansible will treat<!-- .element: class="fragment" data-fragment-index="1" --> _executable_ files in inventory path as dynamic inventory scripts
  * Configured in `ansible.cfg`
  * Passed to command line option `-i`
  <pre class="fragment" data-fragment-index="2" ><code data-trim data-noescape>
  $ ansible-playbook -i <mark>ansible/inventory</mark> \ 
              ansible/playbook.yml
  </code></pre>


####  Dynamic Inventories

* Dynamic inventory scripts available for different applications <!-- .element: class="fragment" data-fragment-index="0" -->
  - <!-- .element: class="fragment" data-fragment-index="1" --><a href="https://raw.github.com/ansible/ansible/devel/contrib/inventory/cobbler.py">Cobbler</a> 
  - <!-- .element: class="fragment" data-fragment-index="2" --><a href="https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py">AWS</a> 
  - <!-- .element: class="fragment" data-fragment-index="3" --><a href="https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py">OpenStack</a> 
 * In<!-- .element: class="fragment" data-fragment-index="4" --> upgrade-strategies ansible inventory 
    ```
    $ ./inventory/openstack.py --list
    ```


#### The provision playbook

* Works similar to previous exercise
* Slightly different preflight steps
* Need to explicitly create hosts with some inventory data and groups
  ```
    - name: Add loadbalancer to inventory
      add_host:
        name: "{{ prefix }}-lb-{{ app_version }}"
        groups: mycluster,loadbalancer,mycluster_new,loadbalancer_new
  ```
* Need this section for _deploy_ so this play factored into separate file


#### Create our new cluster

```
$ ansible-playbook -i ansible/inventory \
     ansible/provision-hosts.yml \
      -K --ask-vault-pass \
      -e prefix=$(hostname) \
      -e app_version=v1
```
  


#### Query dynamic inventory

* Once hosts have been created, our dynamic inventory will provide more
  information

```
$ ansible/inventory/openstack.py --list
```


#### The deploy playbook

#### Deploy our application

* Run the deploy playbook to install our application

```
$ ansible-playbook -i ansible/inventory \
      -K --ask-vault-pass \
      -e prefix=$(hostname) \
      -e app_version=v1 \
      ansible/deploy.yml 
```
* Once this finishes, you should be able to see the <a href="http://my-app.cat">website</a>


#### Upgrade our application

```
$ ansible-playbook -i ansible/inventory \
    -e prefix=$(hostname) \
    -e app_version=v2 \
    --ask-vault-pass -K \
    ansible/expand-update.yml  
```
* Run the upgrade playbook
* Once this finishes, you should see that the <a href="http://my-app.cat">website</a> has updated



#### Tearing down

* Once you're finished please remember to tear everythign down:
* Please run it with `app_version=v1` and again with `app_version=v2`
```
$ ansible-playbook -i ansible/inventory \
     -K --ask-vault-pass \
     -e prefix=$(hostname) \
     -e prefix=$(hostname) \
     -e app_version=v1 \
     ansible/remove-hosts.yml
```


#### Summary

* _Immutable infrastructure_ has become more popular with availability of _on
  demand_ services
* Easier and more cost effective to create new hosts as part of a deploy
* Expand and contract approach has advantages
  - Easier to rollback
  - No configuration drift
* Requires use of dynamic inventories 
