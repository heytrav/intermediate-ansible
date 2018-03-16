# Another upgrade strategy


###  Another upgrade strategy

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



### Expand contract

* Self service on-demand infrastructure has made it more easier and cheaper to create
  hosts
* This strategy involves creating new hosts from scratch
* Advantages
  - Machines are more up-to-date
  - No need to worry about config not managed by Ansible
  - Avoid configuration drift
