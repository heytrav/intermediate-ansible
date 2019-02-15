### Handling failure


#### Handling failure
```
cd $WORKDIR/deploying-code

```


#### Failing fast

* When upgrading an application, it's important to stop if there are problems
* Normally, if an error occurs on a particular host, Ansible will
  - Drop that host from the list of play hosts
  - Proceed to process the play on all other hosts
* This presents a problem as we may progressively crash all other hosts on same error


#### Failing fast

* Have a look at `failhosts.yml` and `inventory/failhosts`
* Run the playbook:
  ```
  $ ansible-playbook -i inventory/failhosts \
      failhosts.yml --ask-vault-pass
  ```
* The first task fails for `failhost10`
* Play proceeeds to run for `failhost0` thru `failhost9`


#### Stopping on any error

##### `any_errors_fatal`

* Tells Ansible to consider operation a failure if an error occurs on one host
  <!-- .element: class="fragment" data-fragment-index="0" -->
  <pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
  - name: Any errors fatal example
    hosts: failhosts
    gather_facts: false
    <mark>any_errors_fatal: true</mark>
    tasks:
  </code></pre>
* Now <!-- .element: class="fragment" data-fragment-index="2" -->if the first task fails for `failhost10`, the entire play will be aborted at the first task


#### Failing based on proportion

##### `max_fail_percentage`

* Defines a percentage of hosts that can fail before operation is aborted <!-- .element: class="fragment" data-fragment-index="0" -->
  <pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
  - name: Max fail percentage
    hosts: failhosts
    gather_facts: false
    <mark>max_fail_percentage: 20</mark>
    tasks:
  </code></pre>
* With previous example, playbook finishes because 10% &lt; 20% <!-- .element: class="fragment" data-fragment-index="2" -->

