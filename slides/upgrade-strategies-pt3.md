## Upgrade strategies

### Blue Green



#### Blue-Green Deployments

![bluegreen](img/blue_green_deployments.png "Blue Green deployment strategy")
<!-- .element: height="40%" width="40%" -->

* Two<!-- .element: class="fragment" data-fragment-index="0" --> identical production environments designated _blue_ and _green_ 
* Blue<!-- .element: class="fragment" data-fragment-index="1" --> environment is _live_ and handles all traffic 
* Green<!-- .element: class="fragment" data-fragment-index="2" --> environment is _idle_ 


#### Blue-Green Upgrade

![bluegreen](img/blue_green_deployments.png "Blue Green deployment strategy")
<!-- .element: height="40%" width="40%" -->

* Final<!-- .element: class="fragment" data-fragment-index="0" --> stage of testing new production code takes place on the _green_ environment 
* When<!-- .element: class="fragment" data-fragment-index="1" --> checks and testing has completed, traffic is switched to _green_ 
  environment
* Updates<!-- .element: class="fragment" data-fragment-index="2" --> to production code installed on _blue_ environment 



####  Adapting previous model

* Blue-green very similar to rolling in place upgrade model
* In place upgrade
  - Start with only _blue_ cluster live in loadbalancer
  - Upgrade _green_ cluster first
  - Once checks have passed switch loadbalancer to _green_
  - Upgrade _blue_ cluster

