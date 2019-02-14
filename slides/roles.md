### Roles 
##### Part 2


#### Reusing Ansible
```
cd $WORKDIR/ansible-roles
```
* Roles make it easy to distribute/reuse Ansible tasks
* Distribute via conventional source code management tools
* Open Source your Ansible


#### Importing roles
* The <!-- .element: class="fragment" data-fragment-index="0" -->`ansible-galaxy` command line tool can be used to import roles from
  different sources
* Install a role from Ansible Galaxy <!-- .element: class="fragment" data-fragment-index="1" -->
   ```
   ansible-galaxy install  role-name
   ```
* Install version 1.0.0 of a role from a repository on GitHub <!-- .element: class="fragment" data-fragment-index="2" -->
   ```
   ansible-galaxy install git+https://github.com/user/role-name.git,1.0.0
   ```
   <!-- .element: style="font-size:13pt;"  -->
* Use the role in your playbook <!-- .element: class="fragment" data-fragment-index="3" -->
   ```
   role:
     - role: role-name
   ```


#### Distributing your Roles
* Using/importing 3rd party roles in your code is easy
* Real benefit is distributing your own roles
* Also easy


##### Exercise: Distributing a Role
* The `ansible-roles` directory contains a very basic role
   ```
   sample-code/ansible-roles
   └── my-role
       └── tasks
           └── main.yml
   ```
* Let's make it ready for distribution


#### Making a Role *distributable*
* Need to fill in <!-- .element: class="fragment" data-fragment-index="0" -->*meta* information about dependencies
* <!-- .element: class="fragment" data-fragment-index="1" -->Create a `meta` subfolder with a *main.yml* file
   <pre><code data-trim data-noescape>
└── my-role
<mark>  ├── meta
    │  └── main.yml</mark>
    └── tasks
        └── main.yml</code></pre>


##### Setting up dependencies
* <!-- .element: class="fragment" data-fragment-index="0" -->Dependencies tell `ansible-galaxy` to pull in other related roles
   ```
   # meta/main.yml
   dependencies:
     - role: antonchernik.nodejs
     - role: my-other-role
       vars: 
         someattribute: green
   ```
* Must be defined, even if you have no dependencies <!-- .element: class="fragment" data-fragment-index="1" -->
* <!-- .element: class="fragment" data-fragment-index="2" -->Perfectly normal to have an empty dictionary
   ```
   # meta/main.yml
   dependencies:
   ```


#### Distributing your Role
* Once you have defined dependencies you are ready to distribute your role
* Simply upload to your SCM of choice
* Assume you have pushed to http://github.com/myaccount/my-role.git repo
  ```
  ansible-galaxy install git+https://github.com/myaccount/my-role.git
  ```
  <!-- .element: style="font-size:13pt;"  -->


#### Managing roles in a project
* Your project might depend on a number of roles
* Adding/tracking each manually can get tedious
* Use a *requirements.yml* file


#### Role Requirements File
* A YAML file (surprise)
* Specify a list of requirements with URL, version, and local name
   ```
    - src: git@github.com/my-account/my-role.git
      scm: git
      version: master
      name: my-role

    - src: some-other-role
      version: 1.0
   ```
* Place this file in your project somewhere 


#### Install roles using a requirements file
* Use `ansible-galaxy` command line tool as before
   ```
   ansible-galaxy install -r requirements.yml
   ```
* Wash, rinse, repeat



#### Summary
* Anisble roles useful way to distribute reusable tasks
* Combined with requirements file, very useful way to manage infrastructure
  dependencies
