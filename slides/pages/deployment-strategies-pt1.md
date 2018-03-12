# Deploying applications


### Deploying applications

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
$ cd $WORKDIR/project
$ tree
.
├── ansible
│   ├── <mark>provision-hosts.yml</mark>
│   ├── <mark>deploy-app.yml</mark>
.
.
├── templates
│   └── index.html
└── wsgi.py
</code></pre>

* This lesson sets up a web application that we'll be using to explore
  upgrades later <!-- .element: class="fragment" data-fragment-index="1" -->



### Provisioning machines

```
- name: Provision a set of hosts in Catalyst Cloud
  hosts: localhost
  tasks:
    - name: Connect to Catalyst Cloud
    - name: Create keypair
    - name: Create subnet
    - name: Create router
    - name: Create cluster instances
```
* The<!-- .element: class="fragment" data-fragment-index="0" --> `provision-hosts.yml` playbook runs tasks for _provisioning_ hosts in OpenStack
* These tasks are fairly idiomatic <!-- .element: class="fragment" data-fragment-index="1" -->
* In fact, we should probably make a<!-- .element: class="fragment" data-fragment-index="2" --> **role** out of this  


#### Exercise: Refactor catalyst cloud tasks in `provision-hosts.yml` playbook

* Create a role called _os-provision_
* Move tasks into role
  ```
  tasks:
    - name: Connect to Catalyst Cloud
      .
      .
    - name: Append floating ip to host info
  ```
* Use role in `provision-hosts.yml`
* Change remaining tasks to `post_tasks`


#### Provisioning role

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
.
├── ansible
│   ├── provision-hosts.yml
│   <mark>├── roles
│   │   └── os-provision
│   │       └── tasks
│   │           └── main.yml</mark>
</code></pre>
<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
<mark>  roles:
    - role: 'os-provision'

  post_tasks:</mark>

    - name: Remove floating ip from known hosts
</code></pre>



### Deploy our application

```
$ cat ~/credentials.txt
$ source ~/os-training.catalyst.net.nz-openrc.sh 
# prompts for password
$ ansible-playbook -e suffix=-$(hostname) -K \
    --ask-vault-pass ansible/provision-hosts.yml
# Prompts for sudo and vault password
```


### Deploying our application

* The<!-- .element: class="fragment" data-fragment-index="0" --> `deploy-app.yml` playbook configures machines and deploys our



### Application stack

* nginx server
* Python Flask application
* DB server
* all behind load balancer
![Basic network diagram](img/application-lb.svg  "Diagram of our simple app")



### Security setup

![Network security Diagram](img/application-security.svg "Networking security") <!-- .element: class="fragment" data-fragment-index="0" -->
* Load balancer has public IP open on ports 80, 443 <!-- .element: class="fragment" data-fragment-index="1" -->
* All hosts only SSH accessible via bastion host <!-- .element: class="fragment" data-fragment-index="2" -->



# Strategies for upgrading applications


### In-place upgrades

* Operates on infrastructure that already exists <!-- .element: class="fragment" data-fragment-index="0" -->
* Typically have multiple hosts behind a load balancer (LB) <!-- .element: class="fragment" data-fragment-index="1" -->
* To update, a subset of servers will be  <!-- .element: class="fragment" data-fragment-index="2" -->
  - disabled at LB <!-- .element: class="fragment" data-fragment-index="3" -->
  - upgraded <!-- .element: class="fragment" data-fragment-index="4" -->
  - re-enabled <!-- .element: class="fragment" data-fragment-index="5" -->
* Repeat process across pool <!-- .element: class="fragment" data-fragment-index="6" -->
* Mixed versions will be running for a period of time <!-- .element: class="fragment" data-fragment-index="7" -->

