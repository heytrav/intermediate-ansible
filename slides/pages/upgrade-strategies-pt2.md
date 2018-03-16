# Expand and contract


###  Expand and contract

```
$ cd $WORKDIR/project2
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

* Easier and cheaper to create servers on-demand
* This strategy involves creating new hosts from scratch
* Advantages
  - Machines are more up-to-date
  - No need to worry about config not managed by Ansible
  - Avoid configuration drift
  - Rolling back much easier
