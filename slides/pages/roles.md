# Roles


### Roles

```
$ cd $WORKDIR/lesson2
.
├── ansible
│   ├── group_vars
│   │   └── all.yml
│   ├── hosts
│   ├── project.yml
│   ├── roles
│   ├── secrets.yml
│   ├── tasks
│   └── templates
│       └── config.py.j2
└── ansible.cfg
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

* Create directory called _myapp_ under _roles_
  
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

