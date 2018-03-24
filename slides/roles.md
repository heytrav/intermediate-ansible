# Roles


### Roles

```
$ cd $WORKDIR/lesson2
.
├── group_vars
│   └── all.yml
├── hosts
├── project.yml
├── secrets.yml
└── templates
    └── config.py.j2
```


### Making tasks reusable

* At some point in your development/refactoring process, you may come across
  bits that will be useful across multiple projects
* Important to follow _DRY_ (don't repeat yourself) principles in infrastructure code
* _Roles_ are mechanism for reusing code in Ansible
  - within a project
  - accross multiple projects


### Basic concepts

* Roles typically designed for a specific purpose
* Roles are not executable on their own
* Can be distributed multiple ways:
  - In `roles` subdirectory in the same place your playbooks live
  - In `/etc/ansible/roles` directory
  - Custom location configured in `ansible.cfg`

  ```
  [defaults]
  roles_path = ~/ansible_roles
  ```


### Components of a role

* tasks
  - tasks that the role will perform
* files
  - Files that will be uploaded
* templates
  - Jinja2 templates that the role will use
* handlers
  - Handlers that will be called from tasks



### Components of a role (continued)

* vars
  - Variables needed by role (shouldn't be overridden)
* defaults
  - Variables that can be overridden
* meta
  - Dependency information


### Structure of a role
  
```
  /roles
    └── role_name
        ├── defaults
        │   └── main.yml
        ├── files
        │   └── someconfig.conf
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── tasks
        │   └── main.yml
        ├── templates
        │   └── sometemplate.j2
        └── vars
            └── main.yml
```
  * Each of these files/folders is optional


### File and directory naming conventions

* The naming of components correspond to directories in the role
* Ansible will look in these directories automatically when running a role
* YAML files named `main.yml` will be loaded automatically when role is
  executed
* Nearly all components are optional


### Creating roles

* Imagine our playbook has some tasks that could be reusable in other projects

<pre><code data-trim data-noescape>
- name: My playbook
  hosts: somehosts
  tasks:
<mark>    - name: myapp task 1
    - name: myapp task 2
    - name: myapp task 3
    - name: myapp task 4</mark>
    - name: some task
</code></pre>


### Refactor tasks into role

* Create directory under the _roles_ directory to put your role
  
  ```
  $ mkdir -p ansible/roles/myapp
  $ mkdir -p ansible/roles/myapp/tasks
  ```
* Put your tasks into `ansible/roles/myapp/tasks/main.yml`

  ```
  - name: myapp task 1
  - name: myapp task 2
  - name: myapp task 3
  - name: myapp task 4
  ```


### Use role in your playbook

<pre><code data-trim data-noescape>
- name: My playbook
  hosts: somehosts
<mark>  roles:
    - myapp</mark>
  tasks:

    - name: some task
</code></pre>
<pre class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: My playbook
  hosts: somehosts
<mark>  roles:
   - role: myapp
     var1: "{{ somevar }}"</mark>
  tasks:

    - name: some task
</code></pre>



### Exercise: Refactor `project.yml` into roles

* The `project.yml` playbook tasks can be broken down into a couple of groups
  - Installing libraries
  - Checking out code
  - Setting up a database
* See if we can break them up into some useful roles



#### Moving app related tasks

* Take tasks related to installing the application and move them into their
  own role

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Check out code for project
    - name: Create python virtual environment
    - name: Add app config
</code></pre>
<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
├── roles
│   <mark>├── catapp
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── config.py.j2</mark>
</code></pre>



#### Moving db related tasks

* Take tasks related to installing the database and move them into their own role
* Note you will also need to move the handler to the db role
<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
    - name: Create DB user
    - name: Make postgres listen on external ports
    - name: Add pb_hba rule for hosts
    - name: Create the database
    - name: Create table for pics 
    - name: Add images to new table
</code></pre>
<pre  class="fragment" data-fragment-index="1"><code data-trim data-noescape>
├── roles
│   ├── catapp
│   <mark>└── db
│       ├── handlers
│       │   └── main.yml
│       └── tasks
│           └── main.yml</mark>
</code></pre>


#### Importing the roles

* Let's add the new roles to our `project.yml`

<pre  class="fragment" data-fragment-index="0"><code data-trim data-noescape>
- name: Set up python application
  hosts: localhost
  vars_files:
    - secrets.yml
  vars:
    database_user: admin
    database: cat_pics
    database_host: localhost
  environment:
    PGPASSWORD: "{{ vault_database_password }}"
  <mark>roles:
    - role: catapp
    - role: db</mark>
</code></pre>


#### Pre and post tasks

* We still need to make sure that the apt modules runs before
  anything else happens
* Changing these into a *pre_task* ensures it will run before the roles do

<pre class="fragment" data-fragment-index="0"><code data-trim data-noescape>
  <mark>pre_tasks:</mark>

    - name: Update apt cache
      become: yes
      apt:
        update_cache: yes
</code></pre>


### Open source roles

[Ansible Galaxy](https://galaxy.ansible.com)

* A repository of ansible roles
* Thousands of opensource roles for any purpose
* Can be easily imported into your projects


### Summary

* Roles provide useful way to reuse code accross projects
  - Simple to include
* Designed to facilitate automation
  - Directory structure
  - Naming conventions
* Ansible Galaxy is an Open Source repository of roles available for all
  purposes
