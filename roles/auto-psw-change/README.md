Automatic password change
=========

This role is intended to automatically renew passwords for users whose password expiration date is within the next seven days. New passwords are generated as part of the playbook execution. All passwords are securely stored in a PostgreSQL database located on the automation host running the playbook.

Requirements
------------

A PostgreSQL-DB  with at least one table which contains the following columns:
- hostname
- username
- password

Ansible collections you need:
- community.general
- community.postgresql


Role Variables
--------------

No role-vars required. Edit the vars main.yml to your liking. 

Example Variables
-----------------

Take a look into the vars main.yml

Example Playbook
----------------

    ---
    - name: Run role
      hosts: servers
      become: true
      
      roles:
        - auto-psw-change

License
-------

free for private use

Author Information
------------------

How do i contact you ? Don`t worry I'll find you :)

