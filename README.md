infrastructure
==============

somthing in infrastructure

Git
---

To add changes on this repository, use feature branch.

~~~
git checkout develop    # Start from develop branch
git pull                # Fetch latest data from remote (github)
git branch feature/TASK # Create new branch named "feature/TASK".  Replace with task number on Onigiri
~~~

When you create the feature branch, move on it and add some commits.

~~~
git checkout feature/TASK # Move to feature/TASK
git add .
git commit
~~~

When you get ready, push your feature branch to remote.

~~~
git checkout feature/TASK
git push origin feature/TASK
~~~

When the branch is merged to develop, remote branch will be removed by reviewer.  You may need to remove your local branch by your self.

~~~
git checkout develop
git branch -D feature/TASK
~~~

Ansible
-------

### Usage for wordpress_template (dry run)

~~~
$ cd ansible/
$ ansible-playbook -i base-template wordpress_template.yml --private-key=~/.ssh/sova --check
~~~


- This role updates base instance (182.48.4.5). 
- Wordpress version and plugins are listed in [ansible/group_vars/all](https://github.com/ADIDDEV/infrastructure/blob/develop/ansible/group_vars/all).
- Tasks in this role are in one file [ansible/roles/wordpress_template/tasks/wordpress_install.yml](https://github.com/ADIDDEV/infrastructure/blob/develop/ansible/roles/wordpress_template/tasks/wordpress_install.yml)
- registered in jenkins <http://jenkins.adid.sg/job/sova-create-wordpress-template/>

### Usage for sovafree_ssh

~~~
# cd ansible
# ansible-playbook -i hosts.txt sovafree-ssh.yml --extra-vars "state=BACKUP virtual_router_id=70 priority_id=100 virtual_ipaddress=10.1.20.249"
~~~

- Change the value 
  - state
  - virtual_router_id
  - priority_id
  - virtual_ipaddress

### Usage for zabbix-proxy

~~~
# cd ansible
# ansible-playbook -i hosts.txt zabbix_proxy.yml
~~~

### Usage for openvz_master

~~~
# cd ansible
# ansible-playbook -i hosts.txt openvz_master.yml
~~~

- After, Need to set the owp.(https://onigiri.adid.sg/projects/5851/wikis/6428) 

### Usage for openvz_server (openvz slave)

~~~
# cd ansible
# ansible-playbook -i hosts.txt openvz_server.yml
~~~

- Need server restart

### Usage for openvz_server in physical (openvz slave)

~~~
# cd ansible
# ansible-playbook -i hosts.txt sovafree_openvz_server.yml --private-key=~/.ssh/sova
~~~

- Need server restart
- Add ansible/host_vars/sovafreeXX

### Usage for sovafree_template

~~~
# cd ansible
# ansible-playbook -i hosts.txt sovafree_template.yml --private-key=~/.ssh/sova
~~~

### Usage for sovafree_ldap

~~~
# cd ansible
# ansible-playbook -i hosts.txt sovafree_ldap.yml --private-key=~/.ssh/sova
~~~

### Usage for sovafree_sftp

~~~
# cd ansible
# ansible-playbook -i hosts.txt sovafree_sftp.yml --private-key=~/.ssh/sova
~~~

- Need to change group_vars/all
  - sftp_virtual_router_id: 80
  - sftp_virtual_ipaddress: 103.250.203.252

### Usage for physical_server_setup

~~~
# cd ansible
# ansible-playbook -i hosts.txt physical_server_setup.yml --private-key=~/.ssh/sova
~~~

### Usage for add_vlan_bridge

~~~
# cd ansible
# ansible-playbook -i hosts.txt add_vlan_bridge.yml --extra-vars "vlan_id=9" --private-key=~/.ssh/sova
~~~

- Need to change vlan_id

### Usage for midx_ldap

~~~
# cd ansible
# ansible-playbook -i hosts.txt midx_ldap_server.yml
~~~

### Usage for midx_ldap_client_private

~~~
# cd ansible
# ansible-playbook -i hosts.txt midx_ldap_client_private.yml
~~~

- This ldap-lient has 192.168.70.0/24 network.

### Usage for midx_ldap_client_global

~~~
# cd ansible
# ansible-playbook -i hosts.txt midx_ldap_client_global.yml
~~~

- This ldap-client does not have 192.168.70.0/24 network.

### Usage for sova_vm_common

~~~
# cd ansible
# ansible-playbook -i hosts.txt sova_vm_common.yml --private-key=~/.ssh/sova
~~~

### Usage for sova_cdn_dev and sova_cdn

This recipe can update vcl on cdn server.

#### for development environment

~~~
# cd ansible
# ansible-playbook -i hosts.txt sova_cdn_dev.yml --private-key=~/.ssh/sova
~~~

#### for production environment

~~~
# cd ansible
# ansible-playbook -i hosts.txt sova_cdn.yml --private-key=~/.ssh/sova
~~~
