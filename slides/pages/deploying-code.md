# Deploying applications


### Deploying applications

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
$ cd $WORKDIR/lesson4
$ tree
.
├── ansible
│   ├── <mark>provision-hosts.yml</mark>
│   ├── <mark>deploy.yml</mark>
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

![Basic app](img/simple-lesson4-app.svg "opt title")
* Web server running nginx
* App server running a Python Flask web application
* A database
* All behind a loadbalancer


### Provisioning machines

* The<!-- .element: class="fragment" data-fragment-index="0" --> `provision-hosts.yml` playbook contains several plays 
  * Preflight plays to set up variables <!-- .element: class="fragment" data-fragment-index="1" -->
  * Provision openstack instances <!-- .element: class="fragment" data-fragment-index="3" -->
    - Create network infrastructure <!-- .element: class="fragment" data-fragment-index="4" -->
    - Create servers <!-- .element: class="fragment" data-fragment-index="5" -->
    - Set up necessary security groups <!-- .element: class="fragment" data-fragment-index="6" -->
  * Basic setup for machines <!-- .element: class="fragment" data-fragment-index="7" -->


### Preflighting 

* The second play in<!-- .element: class="fragment" data-fragment-index="0" --> `provision-hosts.yml` does not have any tasks 
  ```
    - name: Preflight to set up machine specific variables
      hosts: mycluster
      gather_facts: false
  ```
* Objective is to load inventory variables into<!-- .element: class="fragment" data-fragment-index="1" --> _hostvars_ for later plays 
* Note also that<!-- .element: class="fragment" data-fragment-index="2" --> *gather_facts* is set to false 
  * The hosts in<!-- .element: class="fragment" data-fragment-index="3" --> _mycluster_ do not actually exist yet 
  * Prevents Ansible from trying to create SSH connection with them <!-- .element: class="fragment" data-fragment-index="4" -->


### Provisioning

* When interacting with cloud providers Ansible modules leverage APIs <!-- .element: class="fragment" data-fragment-index="0" -->
  - [AWS](https://docs.ansible.com/ansible/latest/list_of_cloud_modules.html#amazon)
  - [Azure](https://docs.ansible.com/ansible/latest/list_of_cloud_modules.html#azure)
  - [OpenStack](https://docs.ansible.com/ansible/latest/list_of_cloud_modules.html#openstack)
* Actions performed from<!-- .element: class="fragment" data-fragment-index="1" --> _localhost_ 
* In general Ansible will need to <!-- .element: class="fragment" data-fragment-index="2" -->
  - Authenticate with cloud provider <!-- .element: class="fragment" data-fragment-index="3" -->
  - Create network devices <!-- .element: class="fragment" data-fragment-index="4" -->
  - Create machines <!-- .element: class="fragment" data-fragment-index="5" -->


### Preparing your local machine

* Provisioned machines are configured just enough that you
  (and Ansible) can log in via SSH <!-- .element: class="fragment" data-fragment-index="0" -->
* A few<!-- .element: class="fragment" data-fragment-index="1" --> _blockinfile_ tasks in provisioning will make SSH interaction easier 
  - Configure<!-- .element: class="fragment" data-fragment-index="2" --> `~/.ssh/config` 
    * hostname from inventory
    * ssh key checking turned **off**
  - Add entries to<!-- .element: class="fragment" data-fragment-index="3" --> `/etc/hosts`  


### Setting up new hosts

* The next thing we need to do is set up remote machines <!-- .element: class="fragment" data-fragment-index="0" -->
* Ansible modules will not work because Python is not installed <!-- .element: class="fragment" data-fragment-index="1" -->
* Need to <!-- .element: class="fragment" data-fragment-index="2" -->
  - Install Python <!-- .element: class="fragment" data-fragment-index="3" -->
  - Set the locale to NZ <!-- .element: class="fragment" data-fragment-index="4" -->
  - Add entries for other hosts in private network <!-- .element: class="fragment" data-fragment-index="5" -->
* We have a special setup w.r.t. SSH in our cluster <!-- .element: class="fragment" data-fragment-index="6" -->


### Bastion host

![Network security Diagram](img/application-security.svg "Networking security") 
* Only one machine is directly accessible by SSH <!-- .element: class="fragment" data-fragment-index="0" -->
* This host is a<!-- .element: class="fragment" data-fragment-index="1" --> _bastion_ or _jump host_ 
* All other hosts can only be reached from<!-- .element: class="fragment" data-fragment-index="2" -->
 _bastion_ Note: Adds some extra security for our cluster 



### Using Ansible via a bastion host

* Ansible allows us to pass options to SSH for all interactions with a host <!-- .element: class="fragment" data-fragment-index="0" -->
  ```yaml
  ansible_ssh_common_args: >  
      -o StrictHostKeyChecking=no  
      -o ProxyCommand='ssh train@train-pc exec nc -w300 %h %p'"
  ```
* This tells Ansible to<!-- .element: class="fragment" data-fragment-index="1" --> _transparently_ proxy all SSH connections through our bastion 
* This has also been setup in your<!-- .element: class="fragment" data-fragment-index="2" --> `~/.ssh/config` 
  ```yaml
  ProxyCommand ssh train@train-pc exec nc -w300 %h %p
  ```


### Load balanced application

* We are setting up multiple web and app instances
  - Redundancy
  - High availability
![Basic network diagram](img/application-lb.svg  "Diagram of our simple app")


### Managing multiple hosts with inventory

* Sets of hosts can be trivially managed in the inventory file <!-- .element: class="fragment" data-fragment-index="0" -->
* Bracket syntax<!-- .element: class="fragment" data-fragment-index="1" --> `[x:y]` managed hosts from `x` to `y` inclusive 
* These are equivalent <!-- .element: class="fragment" data-fragment-index="2" -->

<div  class="fragment" data-fragment-index="3" style="width:45%;float:left;" >
<pre ><code data-trim data-noescape>
[web]
train-web1
train-web2
[app]
train-app1
train-app2
</code></pre>
</div>
<div  class="fragment" data-fragment-index="4" style="width:45%;float:right;" >
<pre ><code data-trim data-noescape>
[web]
train-web[1:2]
[app]
train-app[1:2]
</code></pre>
</div>


### Provision cloud machines

Let's go ahead and provision our machines
```
$ cat ~/credentials.txt
$ source ~/os-training.catalyst.net.nz-openrc.sh 
# prompts for password
$ ansible-playbook -i ansible/inventory/hosts \
   -e prefix=$(hostname) -K \
    --ask-vault-pass ansible/provision-hosts.yml
# Prompts for sudo and vault password
```


### Deploying our application

* Once machines provisioned, time to set up individual hosts for assigned jobs
* Database server
  - Runs postgresql database
* Web server
  - Runs nginx
  - Sends request through to app server
* App server
  - Runs Python web application
* Loadbalancer
  - Sends HTTP requests to web server



### Deploying our application

```
$ ansible-playbook -K --ask-vault-pass ansible/deploy.yml
```

* The<!-- .element: class="fragment" data-fragment-index="0" --> `deploy.yml` playbook:
  - configures machines 
  - sets up database
  - deploys our web application
  - Configures the loadbalancer to direct HTTP between web1 and web2
* Should be able to access your new <!-- .element: class="fragment" data-fragment-index="1" --> <a href="http://my-app.cat">web application</a> 


### Refactoring our lesson4

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
$ sudo mkdir -p $WORKDIR/lesson4/ansible/roles
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
* Create a role called<!-- .element: class="fragment" data-fragment-index="1" --> _common_ in `$WORKDIR/lesson4/ansible/roles` next to _os-provision_ role

<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
/.
├── ansible
│   ├── roles
│   │   ├── os-provision
│   │   └── common
│   │       └── tasks
│   │           └── main.yml
</code></pre>
