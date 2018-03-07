# Task state


## Ignore errors

#### `ignore_errors`

Tell Ansible to continue execution when an error happens
```
    - name: Task that checks out fake repository
      git:
        repo: git@github.com/fake/repo.git
        dest: /some/path
      ignore_errors: true
```


## Error state

* Modules generally know how to interpret task error
* Sometimes necessary to control how Ansible handles error
  - command
  - script
  - shell
  - raw



## Defining failed state

#### `failed_when`

* Define when ansible should interpret a task has failed
* Similar to _when_ usage
* Use with _register_ to capture stdout/stderr


## Command errors

In `project.yml`:
```
    - name: Add images to new table
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "INSERT INTO images (image) VALUES ('{{ item }}')" {{ database }}
      with_items: "{{ images }}"
```
* Can be run once
* Following attempts trigger error due to unique constraint
* Only really consider failed when:
  - result code is 1 AND
  - not a duplicate error


### Exercise: Allow task to pass on duplicate errors

* Use _register_ to capture stdout/stderr

<pre class="fragment" data-fragment-index="0"><code data-noescape data-trim >
    - name: Add images to new table
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "INSERT INTO images (image) VALUES ('{{ item }}')" {{ database }}
      with_items: "{{ images }}"
      <mark class="fragment" data-fragment-index="1">register: db_insert</mark>
      <mark class="fragment" data-fragment-index="2">failed_when: db_insert.rc != 0 and 'duplicate' not in db_insert.stderr</mark>

</code></pre>

* rerun the playbook <!-- .element: class="fragment" data-fragment-index="3" -->


## Defining changed state

```
    - name: Create table for pics 
      command: |
        psql -U {{ database_user }} -h {{ database_host }} 
        -c "CREATE TABLE IF NOT EXISTS images (id SERIAL primary key not null,
        image char(200) not null unique)" {{ database }}
```
* Table only created on first run
* Task always registers as _changed_



## Changed state

#### `changed_when`







