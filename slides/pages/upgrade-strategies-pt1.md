# Strategies for upgrading applications


### Load balanced application

![Basic network diagram](img/application-lb.svg  "Diagram of our simple app")
* Often multiple clusters behind loadbalancer for redundancy and scalability


### Ensuring no downtime

* Essential that we can upgrade without taking application offline
* Core feature of Ansible is that it operates on multiple hosts at a time
* However, if we allow ansible to start upgrading all hosts at once we could
  create a considerable mess


### Upgrading all hosts

* Risk of disrupting entire operation
  - Could be bad for business
![update all at once](img/cluster-non-serial-update.svg "All at once upgrade")


### In-place upgrades

* Operates on infrastructure that already exists <!-- .element: class="fragment" data-fragment-index="0" -->
* Goal is to minimize downtime <!-- .element: class="fragment" data-fragment-index="1" -->
* Traditional model <!-- .element: class="fragment" data-fragment-index="2" -->
  - Cost and effort of creating new infrastructure 



### First step of in place upgrade

![step2](img/cluster-update-step1.svg "Upgrade first cluster")

* Disable application at LB (no HTTP requests) <!-- .element: class="fragment" data-fragment-index="0" -->
* Upgrade necessary applications, configuration <!-- .element: class="fragment" data-fragment-index="1" -->
* Re-enable at LB <!-- .element: class="fragment" data-fragment-index="2" -->


### In place rolling upgrade
![step3](img/cluster-update-step-2.svg "Upgrade other clusters")

* Repeat process across pool <!-- .element: class="fragment" data-fragment-index="0" -->
* Mixed versions will be running for a period of time <!-- .element: class="fragment" data-fragment-index="1" -->


### Managing a rolling upgrade

#### The `serial` attribute

* By default Ansible will act on multiple hosts at once <!-- .element: class="fragment" data-fragment-index="0" -->
* We need to change this behaviour <!-- .element: class="fragment" data-fragment-index="1" -->
* The<!-- .element: class="fragment" data-fragment-index="2" --> `serial` attribute in a play tells Ansible to only work on a fixed number of hosts at a time


### Using the `serial` attribute

* Serial can be represented as <!-- .element: class="fragment" data-fragment-index="0" -->
  * An integer <!-- .element: class="fragment" data-fragment-index="1" -->
  * A percentage of hosts in the cluster to act on <!-- .element: class="fragment" data-fragment-index="2" -->

<pre  class="fragment" data-fragment-index="3"><code data-trim data-noescape>
- name: Upgrade application in place
  become: true
  hosts: app
  <mark>serial: 1</mark>
  vars:
</code></pre>
<pre  class="fragment" data-fragment-index="4"><code data-trim data-noescape>
- name: Upgrade application in place
  become: true
  hosts: app
  <mark>serial: "30%"</mark>
  vars:
</code></pre>


### Delegation

* The application that we need to update is on our app servers <!-- .element: class="fragment" data-fragment-index="0" -->
* However, as part of updating, we need to control haproxy on our loadbalancer
  <!-- .element: class="fragment" data-fragment-index="1" -->
* Key to this is the<!-- .element: class="fragment" data-fragment-index="2" --> `delegate_to` task attribute 

<pre class="fragment" data-fragment-index="2"><code data-trim data-noescape>
- name: Upgrade application in place
  <mark>hosts: app</mark>
  serial: 1
  tasks:
    - name: Disable application at load balancer
      haproxy:
        .
        .
      <mark>delegate_to: "loadbalancer"</mark>
</code></pre>


### Ensuring healthy update

* After upgrading the application or config, typically want to <!-- .element: class="fragment" data-fragment-index="0" -->
  - Restart service that was upgraded <!-- .element: class="fragment" data-fragment-index="1" -->
  - Re-enable at loadbalancer <!-- .element: class="fragment" data-fragment-index="2" -->
* Before proceeding important to <!-- .element: class="fragment" data-fragment-index="3" -->
  - Reload or restart our service <!-- .element: class="fragment" data-fragment-index="4" -->
  - Make sure service is<!-- .element: class="fragment" data-fragment-index="5" --> _healthy_ 


### Ensuring healthy update

* When we upgrade our application or config we trigger a restart using<!-- .element: class="fragment" data-fragment-index="0" --> _notify_ 

  <pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
  - name: Checkout application from git
    git:
      .
      .
    <mark>notify: restart gunicorn</mark>
  </code></pre>
* Normally this would trigger the handler at the end of a play <!-- .element: class="fragment" data-fragment-index="1" -->
  <pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
  handlers:
    - name: restart gunicorn
      systemd:
        name: gunicorn
        state: restarted
  </code></pre>


### Waiting for a service

* Instead of waiting for handler to execute at the end of play, we trigger it
  immediately<!-- .element: class="fragment" data-fragment-index="0" -->

  <pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
  - name: Checkout application from git
    git:
      .
    notify: restart gunicorn
  <mark>- meta: flush_handlers</mark>
  </code></pre>
* We proceed when we are sure that the service is running <!-- .element: class="fragment" data-fragment-index="1" -->
  <pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
    - name: Make sure app is listening on port 500
      wait_for:
        port: 5000
  </code></pre>


### Failing fast

* When upgrading an application, it's important to stop if there are problems
* Normally, if an error occurs on a particular host, Ansible will
  - Drop that host from the list of play hosts
  - Proceed to process the play on all other hosts
* This presents a problem as we may progressively crash all other hosts on same error


### Failing fast

* Have a look at `failhosts.yml` and `inventory/failhosts`
* Run the playbook:
  ```
  $ ansible-playbook -i ansible/inventory/failhosts \
      ansible/failhosts.yml --ask-vault-pass
  ```
* The first task fails for `failhost10`
* Play proceeeds to run for `failhost0` thru `failhost9`


### Stopping on any error

#### `any_errors_fatal`

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


### Failing based on proportion

#### `max_fail_percentage`

* Defines a percentage of hosts that can fail before operation is aborted <!-- .element: class="fragment" data-fragment-index="0" -->
  <pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
  - name: Max fail percentage
    hosts: failhosts
    gather_facts: false
    <mark>max_fail_percentage: 20</mark>
    tasks:
  </code></pre>
* With previous example, playbook finishes because 10% &lt; 20% <!-- .element: class="fragment" data-fragment-index="2" -->


### Update our application

* Open $WORKDIR/project/templates/index.html
* Edit color of background for application

