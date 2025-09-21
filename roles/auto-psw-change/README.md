Automatic password change
=========

This role is designed to automatically renew all password for a certain range of users whos password expiration dateis smaller then 7 days. New passwords are generated in the playbook. All passwords are meant to be safed inside a postgresDB on the automation-host which is running the playbook.  

Requirements
------------

A postgresDB  with at least one table which contains the following columns
- hostname
- username
- password


Role Variables
--------------

No role-vars required. Edit the vars main.yml to your liking. 

Example Variables
-----------------

Take a look into the vars main.yml

Example Playbook
----------------

    ---
    - name: test run for role
    - hosts: servers
      roles:
        - auto-psw-change

License
-------

free for private use

Author Information
------------------

How do i contact you ? Don`t worry I'll find you :)

