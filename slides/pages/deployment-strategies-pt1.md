# Deploying applications



### Deploying applications

```
$ cd $WORKDIR/project
$ tree
.
├── ansible
│   ├── deploy-app.retry
.
.
.
├── templates
│   └── index.html
└── wsgi.py
```


### Application stack

* nginx server
* Python Flask application
* DB server
* all behind load balancer
![Basic network diagram](img/application-cluster-bg.svg  "Diagram of our simple app")


### Deploy our application

```
$ ansible-playbook -K --ask-vault-pass ansible/provision-hosts.yml -e suffix=-$(hostname)
```

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

