# Strategies for upgrading applications


### Load balanced application

![Basic network diagram](img/application-lb.svg  "Diagram of our simple app")
* Often multiple clusters behind loadbalancer for redundancy and scalability


### Ensuring no downtime

* Essential that we can upgrade without taking application offline
* Core feature of Ansible is that it operates on multiple hosts at a time
* 


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

