Create certain logical volume
=========

This role is designed to build a certain logical volume. Also the role checks if the lv already exists and if it could be build in the root vg (main vg which contains home, root, var ...).

Requirements
------------

OS is structured with at least one main volume group named like one of the examples in the
vars main.yml.

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
        - create-logical-volume

License
-------

free for private use

Author Information
------------------

How do i contact you ? Don`t worry I'll find you :)
