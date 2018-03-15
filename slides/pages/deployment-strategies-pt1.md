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

* This lesson sets up the<!-- .element: class="fragment" data-fragment-index="1" --> _Cat Pic of the Day_ application 
* We'll be using this demonstrate deploying and later upgrading applications
  <!-- .element: class="fragment" data-fragment-index="2" -->


### Basic application

![Basic app](img/simple-project-app.svg "opt title")
* Web server running nginx
* App server running a Python Flask web application
* A database
* All behind a loadbalancer



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
* A lot of these tasks are idiomatic <!-- .element: class="fragment" data-fragment-index="1" --> 
* In fact, we should probably make a<!-- .element: class="fragment" data-fragment-index="2" --> **role** out of this  


#### Exercise: Refactor catalyst cloud tasks in `provision-hosts.yml` playbook

* Create a role called<!-- .element: class="fragment" data-fragment-index="0" --> _os-provision_ in `/etc/ansible/roles` 
* Move tasks into role<!-- .element: class="fragment" data-fragment-index="1" --> _os-provision_ role 
<pre class="fragment" data-fragment-index="2"><code data-trim data-noescape>
  tasks:
<mark>  - name: Connect to Catalyst Cloud
      .
      .
    - name: Append floating ip to host info</mark>
    - name: Remove floating ip from known hosts
</code></pre>
* Use role in<!-- .element: class="fragment" data-fragment-index="3" --> `provision-hosts.yml` 
* Change remaining tasks to<!-- .element: class="fragment" data-fragment-index="4" --> `post_tasks` 


#### Provisioning role

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
$ sudo mkdir -p $WORKDIR/project/ansible/roles
</code></pre>
<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
.
├── ansible
│   <mark>├── roles
│   │   └── os-provision
│   │       └── tasks
│   │           └── main.yml</mark>
</code></pre>
<pre  class="fragment" data-fragment-index="2"><code data-trim data-noescape>
<mark>  roles:
    - role: 'os-provision'

  post_tasks:</mark>

    - name: Remove floating ip from known hosts
</code></pre>


#### Exercise: Refactor common setup tasks

* The playbook `provision-hosts.yml` still has some repetition
* Two plays do the same thing on different sets of hosts
  - Install python and set up /etc/hosts on bastion host
  - Install python and set up /etc/hosts on rest of cluster
* Let's do the same thing for these tasks and create a _common_ role


#### Refactoring _common_ tasks

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: Basic host setup
  hosts: bastion
  become: true
  gather_facts: false
  tasks:
<mark>    - name: Update apt cache
    - name: Install python
    - name: Add NZ locale to all instances
    - name: Add entry to /etc/hosts for all instances</mark>
</code></pre>

<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
- name: Basic host setup
  hosts: bastion
  become: true
  gather_facts: false
<mark>  roles:
    - role: common</mark>
</code></pre>



#### Refactoring _common_ tasks

* These tasks <!-- .element: class="fragment" data-fragment-index="0" -->will be useful in later lessons 
* Create a role called<!-- .element: class="fragment" data-fragment-index="1" --> _common_ in `$WORKDIR/project/ansible/roles` next to _os-provision_ role

<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
/etc
├── ansible
│   ├── roles
│   │   ├── os-provision
│   │   └── common
│   │       └── tasks
│   │           └── main.yml
</code></pre>



### Provision cloud machines

```
$ cat ~/credentials.txt
$ source ~/os-training.catalyst.net.nz-openrc.sh 
# prompts for password
$ ansible-playbook -e suffix=-$(hostname) -K \
    --ask-vault-pass ansible/provision-hosts.yml
# Prompts for sudo and vault password
```


### Deploying our application

```
$ ansible-playbook -K --ask-vault-pass ansible/deploy-app.yml
```

* The<!-- .element: class="fragment" data-fragment-index="0" --> `deploy-app.yml` playbook:
  - configures machines 
  - sets up database
  - deploys our web application



### Bastion host

* Only one machine in our cluster has a public IP and is accessible by SSH
* This host is a _bastion_ or _jump host_
* All other hosts in our cluster can only be reached by SSH _from_ this host
* Adds some extra security for our cluster


### Using bastion host

![Network security Diagram](img/application-security.svg "Networking security") <!-- .element: class="fragment" data-fragment-index="0" -->
* Load balancer has public IP open on ports 80, 443 <!-- .element: class="fragment" data-fragment-index="1" -->
* All hosts only SSH accessible via bastion host <!-- .element: class="fragment" data-fragment-index="2" -->


### Working with a bastion host

```yaml
ansible_ssh_common_args: >  
    -o StrictHostKeyChecking=no  
    -o ProxyCommand='ssh train@train-pc exec nc -w300 %h %p'"
```
* Ansible allows us to pass options to SSH for all interactions with a host
* This tells Ansible to _transparently_ proxy all SSH connections through our bastion
* This has also been setup in your `~/.ssh/config`


# Strategies for upgrading applications


### Load balanced application

![Basic network diagram](img/application-lb.svg  "Diagram of our simple app")
* Often multiple clusters behind loadbalancer for redundancy and scalability


### In-place upgrades

* Operates on infrastructure that already exists <!-- .element: class="fragment" data-fragment-index="0" -->
* Typically have multiple hosts behind a load balancer (LB) <!-- .element: class="fragment" data-fragment-index="1" -->
* To update, a subset of servers will be  <!-- .element: class="fragment" data-fragment-index="2" -->
  - disabled at LB <!-- .element: class="fragment" data-fragment-index="3" -->
  - upgraded <!-- .element: class="fragment" data-fragment-index="4" -->
  - re-enabled <!-- .element: class="fragment" data-fragment-index="5" -->
* Repeat process across pool <!-- .element: class="fragment" data-fragment-index="6" -->
* Mixed versions will be running for a period of time <!-- .element: class="fragment" data-fragment-index="7" -->


### Update our application

* Open $WORKDIR/project/templates/index.html
* Edit color of background for application

