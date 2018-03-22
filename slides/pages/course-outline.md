## Course Outline


* [Organising Infrastructure Code](includes.md)
    * Including playbooks
    * Including tasks
    * Passing variables to includes
    * Blocks



* [Roles](roles.md)
  * Components of roles
  * Writing a role



* [Task conditions](error-state.md)
  * Interpreting and controlling errors
    - ignoring errors
  * Manipulating task conditions
    - Errors
    - Changed state
  * Error recovery
    - block/rescue


* [Deploying code](deploying-code.md)
  *  Deploying loadbalanced applications
  *  Ansible via a bastion host


* [Set Theory in Ansible](group-set-theory.md)
  *  Set theory filters
  *  Inventory set theory operators


* [In place rolling upgrade](upgrade-strategies-pt1.md)
  *  Serialising upgrades
  *  Delegation
  *  Failing fast


* [Expand and contract](upgrade-strategies-pt2.md)
  * Dynamic inventories
