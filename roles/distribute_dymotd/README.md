Distribute dymotd.sh
=========

This role is designed to distribute a message of the day bash script for all server-admin accounts. The script is getting triggered everytime an admin user starts a shell session.

Requirements
------------

No further ansible collections or roles required.

Role Variables
--------------

No role-vars required. But you have to change the variables in /vars/main.yml. See examples !

Example Variables
-----------------

    ---
    source: .dymotd.sh
    users:
      admin1:
        path: /home/admin1/.dymotd.sh
        dest: /home/admin1
        user: admin1
        group: admin1
      root:
        path: /root/.dymotd.sh
        dest: /root
        user: root
        group: root

Example Playbook
----------------

    ---
    - name: test run for role
    - hosts: servers
      roles:
        - distribute_dymotd

License
-------

free for private use

Author Information
------------------

How do i contact you ? Don`t worry I'll find you :)
