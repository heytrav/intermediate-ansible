# Deploying applications


### Our project

* Server running nginx <!-- .element: class="fragment" data-fragment-index="0" -->
* Python Flask based application listening on app server <!-- .element: class="fragment" data-fragment-index="1" -->
* Database storage <!-- .element: class="fragment" data-fragment-index="2" -->
* Load balancer accepting HTTP requests on port 80 <!-- .element: class="fragment" data-fragment-index="3" -->
![Basic network diagram](img/simple-project-app.svg "Diagram of our simple app")



### Security setup

* Load balancer has public IP open on ports 80, 443 <!-- .element: class="fragment" data-fragment-index="0" -->
* All hosts only SSH accessible via bastion host <!-- .element: class="fragment" data-fragment-index="1" -->

![Network security Diagram](img/application-security.svg "Networking security") <!-- .element: class="fragment" data-fragment-index="2" -->


### In-place upgrades

* Operates on infrastructure that already exists
* Typically have multiple hosts behind a load balancer (LB)
* To update, a subset of servers will be 
  - disabled at LB
  - upgraded
  - re-enabled
* Repeat process across pool
* Mixed versions will be running for a period of time

