# Upgrade strategies

## Expand and contract


###  Expand and contract upgrades

```
$ cd $WORKDIR/lesson7
.
└── ansible
    ├── add-hosts-to-inventory.yml
    ├── check-defined.yml
    ├── deploy.yml
    ├── expand-update.yml
    ├── files
    │   ├── mycluster_rsa.pub
    │   └── rsyslog-haproxy.conf
    ├── group_vars
```


### Expand and contract

* This strategy involves deploying updates on completely new hosts
* Advantages
  - Machines are more up-to-date
  - No need to worry about config not managed by Ansible
  - Avoid configuration drift
  - Rolling back much easier


### Upgrading by expanding contract

![cluster-pre-upgrade](img/expand-contract-pre-upgrade.svg "Pre upgrade")


### Expand phase

![cluster-upgrade-step1](img/expand-contract-upgrade.svg "During upgrade") <!-- .element height="50%" width="50%" -->

* Deploy application update to new machines <!-- .element: class="fragment" data-fragment-index="0" -->
* Current version remains active <!-- .element: class="fragment" data-fragment-index="1" -->


### Change to new cluster

![cluster-upgrade-step2](img/expand-contract-upgrade-2.svg "Post upgrade")<!-- .element height="40%" width="40%" -->

* Once new cluster finished and healthy: <!-- .element: class="fragment" data-fragment-index="0" -->
  - Change DNS to point at new cluster
  - Stop services on old cluster
* Decommision old cluster <!-- .element: class="fragment" data-fragment-index="1" -->

