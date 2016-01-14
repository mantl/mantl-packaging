# Packaging Roadmap for Mantl
#### Rationale
To improve mantl's deployment speed, we are going to replace some
ansible role logic with packages. These packages will be defined by a hammer spec,
and uploaded to bintray. Anything that is as simple as 'copy this file here' 
or 'run this command' can be ported to these packages. Then, the ansible roles can
be updated to simple package install commands

Because we are using the hammer tool to build these, when hammer supports `.deb` packages,
ubuntu/debian support will come much more easily.

Logic that relies upon Jinja2 templates could be ported to Consul templates, 
and those could be ported to packages.

The more ansible roles that we port to packages, the faster the build process will be.
If we can remove ansible entirely, we can have mantl bootstrap from terraform, and
make cluster deployment into a one-step process.

#### Ansible role
Here is the list from the `terraform.sample.yml` ansible playbook. For each role that
we can port to a package, put the package name after it, and list the package description
below, or make a note. I hope that the ad-hoc formatting here makes sense.

*Roles for all hosts*
- common: **mantl-common**
- lvm: **mantl-lvm**
- collectd: **mantl-collectd**
- logrotate: *I think that this one should be split up and managed by each package*
- consul-template: *this is in the same boat as mantl-consul*
- docker: **mantl-docker**
- logstash: **mantl-logstash**
- nginx: **mantl-nginx**
- consul: **mantl-consul**
- dnsmasq: **mantl-dnsmasq**

*Roles for workers*
- mesos: *Secrets should be managed by vault before this is a package*

*Roles for controls*
- vault: **mantl-vault**
- zookeeper: **mantl-zookeeper**
- mesos: **mantl-mesos**
- marathon: **mantl-marathon**
- chronos: **mantl-chronos**
- mantlui: **mantl-mantlui**

*Roles for edges*
- traefik: **mantl-traefik**

#### New packages
These are high level descriptions of some of the packages that we'll make. We can then use these descriptions
to write actual hammer specs and package them.

`mantl-common`



    - pyhon-pip
- Reverse Dependencies 
    - mantl-distributive
    - mantl-consul

-Components

    -defaults/main.yml: selinux with permissive policy and central configuration
    
    -handlers/main.yml: update-ca-trust
    
    -tasks/main.yml
        lines 3-9
            // set time to etc/utc
            // sudo
            // force a symlink to the src file in place of the path
          packaging solutions:
            - set timezone to UTC (`sudo ln -sf /etc/localtime /usr/share/zoneinfo/Etc/UTC`)
            - create `/etc/mantl`, a config dir that along with consul/vault k/v stores, can replace ansible facts
        
        lines 12-19
            // sudo
            // add hosts (hosts.j2) to /etc/hosts
            // set permissions to 644
            // tag is common
          packaging solutions:
             -copy hosts.j2 to /etc/hosts(`sudo cp hosts.j2 /etc/hosts`)
             -set permissions (`sudo chmod 0644 /etc/hosts`)            

        lines 21-33
            // install system utilities
            // sudo
            // update yum packages(yum -y update)
            // dependencies/packages
                - httpd-tools 
                - nc 
                - openssh 
                - policycoreutils-python 
                - unzip
            // tag is bootstrap
          packaging solutions:
            - update packages (`sudo yum -y update httpd-tools nc openssh policycoreutils-python unzip`)                

        lines 35-42
            // sudo
            // firewalld is not started on boot
            // firewalld stopped
            // fails when the output is not "command_result|failed and 'No such file or directory'"
          packaging solutions:
            - disable firewalld (sudo systemctl disable firewalld)
            - if the status is "active (running)", disable has failed(exception handling in bash?)
         
        lines 44-48
            // sudo
            // update or install epel-release
           packaging solutions
           - if it does not exist: sudo yum -y install epel-release
           - if it does exist: sudo yum -y update epel-release
               
        lines 50-54
            // sudo
            // install or update package python-pip
           packaging solutions:
           - if it does not exist: sudo yum -y install python-pip
           - if it does exist: sudo yum -y update python-pip
            
        lines 56-63
            // sudo
            // update pip and setuptools
            // dependencies
                    - pip
                    - setup tools
            packaging solutions:
               sudo yum -y update pip setup tools
        
        lines 65-71
            // sudo
            // install distributive from bintray:
                // https://bintray.com/artifact/download/ciscocloud/rpm/distributive-0.2.1-5.el7.centos.x86_64.rpm
            // tag is distributive
            
        lines 73-80
            lineinfile-ensure that a particular line is in a file, or replace an existing line using a back-referenced                      regular expression
            // sudo
            // disable requiretty in sudoers
                // look for the regular expression ^.+requiretty$ in every line of the file, /etc/sudoers. This regular                         expression should be in this file.
                // replace the last instance of this regular expression with "# Defaults requiretty"
                
        lines 82-89
            // sudo
            // configure selinux
                // set the SELinux policy and the SELinux mode
            // tags are security and bootstrap
            
        lines 91-92
            // sudo
            // dependencies for this file include other files within tasks/
                - users.yml
                - ssl.yml
                
    - tasks/ssl.ym: deploy root ca
        // sudo
        // copy local path ssl/cacert.pem to remote server /etc/pki/ca-trust/source/anchors/cacert.pem
        // root is the owner(chown)
        // notify handler update-ca-trust
        
    - tasks/users.yml
        lines 2-10: configure members of wheel group for passwordlest sudo
            // sudo
            // look in file /etc/sudoersfor regular expression "^%wheel" that should be there
            // replace the last instance of the regular expression with "%wheel ALL=(ALL) NOPASSWD: ALL"
            // users is tag
        
        lines 12-20: create os users
            // sudo
            // name of user needing modification (form of item.name)
            // put the user in the wheel group when item.enabled is defined and item.enabled == 1
            // dependencies
                - users
            // tags is users
            
        lines 22-30: set ssh key for users
            // sudo
            // add an ssh authorized key to the user when the key(item.1) is defined and enabled (item.0.enabled == 1)
            // loop through list of subelements, users|default([]) and pubkeys
            // users is tags
            
        lines 32-41: delete os users
            // sudo
            // if the user exists remove them (userdel --remove) when item.enabled is defined and item.enabled == 0
            // dependencies
                -users
            // users is tags
            
        - templates/hosts.j2
            // sets hosts file, use the template instead of regex
            
`mantl-lvm`
- create volume group, and save the in `etc/mantl`
- enable lvmetad service
- Dependencies
    - mantl-common
    - device-mapper-libs
    - lvm2

`mantl-collectd`

    collectd/files/collectd_docker_plugin.pp
        // 2.52 KB

    collectd/handlers/main.yml: restart collectd
        // sudo
        // service collectd to be restarted
        // tag is collects

    collectd/tasks/main.yml
        // sudo
        // install collectd package
        // Dependencies
            - mantl-collectd
            - libsemanage-python
        // tags are collectd and bootstrap

        line 14
        // sudo
        // create plugins directory /usr/share/collectd/plugins
        // permissions 0755(chmod) 
        // tag is collectd

        line 23
        // sudo
        // collectd.conf.j2 is the path of the Jinja2 formatted template on the local server
        // render the template to /etc/collectd.conf (on remote machine)
        // restart collectd
        // tag is collectd

        line 34: authorizes collectd to make tcp connections
        // sudo
        // name of a SELinux boolean: collect_tcp_network_connect
            // boolean value set to yes
            // persistent: boolean setting should survive a reboot
        //  (direct quote)when: ansible_selinux.status == "enabled" and ansible_selinux.mode == "enforcing"
        // tag is collectd

        line 41: check if collectd is authorized to connect to docker
        // sudo
        // shell: semodule -l
        // register: semodule_list
        // failed_when: no
        // changed_when: no
        // when: ansible_selinux.status == "enabled" and ansible_selinux.mode == "enforcing"
        // tag is collectd

        line 51: copy collectd selinux docker policy
        // sudo
        // copy: src=collectd_docker_plugin.pp dest=/tmp/collectd_docker_plugin.pp owner=root mode=0600
        // when: "semodule_list.stdout is defined and semodule_list.stdout.find('collectd_docker_plugin') == -1"
        // tag is collectd

        line 58: authorize collectd to connect to docker
        // sudo
        shell: semodule -i /tmp/collectd_docker_plugin.pp
        when: "semodule_list.stdout is defined and semodule_list.stdout.find('collectd_docker_plugin') == -1"
        // tag is collectd

        line 65: enable collectd
        // sudo
        // collectd starts on boot
        // start collectd if not running(idempotent actions)

        microservices-infrastructure/roles/collectd/templates/collectd.conf.j2
        //

`mantl-consul`
This package is important during the bootstrapping process,
so it's getting mentioned here
- Dependencies
    - mantl-common

`mantl-docker`
Container manager and scheduler.
- Dependencies
    - lvm
    - docker
    - docker-selinux
    - collectd.yml

`mantl-logstash`
Deploys and manages Logstash 1.5 with Docker and systemd.
- Dependencies

`mantl-nginx`
Web and proxy server.
- Dependencies
    - distributive.yml

`mantl-dnsmasq`
Configures each host to use :doc:`consul` for DNS
- Dependencies
    - dnsmasq
    - bind-utils
    - NetworkManager
    - distributive.yml

`mantl-mesos`
Distributed system kernel that manages resources across multiple nodes. When combined with :doc:`marathon`, you can basically think of it as a distributed init system.

`mantl-vault`
"Secures, stores, and tightly controls access to tokens, passwords, certificates, API keys, and other secrets in modern computing."
- Dependencies
    - bootstrap.yml
    - distributive.yml

`mantl-zookeeper`
ZooKeeper is used for coordination among Mesos and Marathon nodes.
- Dependencies
    - zookeeper_check.sh
    - zookeeper-wait-for-listen.sh
    - zookeeper_digest.sh
    - zookeeper-update-mantl-0.5-0.6.sh
    - collectd.yml
    - distributive.yml

`mantl-marathon`
- Dependencies
    - marathon-consul.cfg
    - nginx-proxy.yml
    - collectd.yml
    - jobs.yml
    - distributive.yml
    
    - key: zk
      value: "{{ marathon_zk_connect }}"
    - key: ssl_keystore_password
      value: "{{ marathon_keystore_password }}"
    - key: http_port
      value: 18080
    - key: event_subscriber
      value: http_callback
    - key: hostname
      value: "{{ inventory_hostname }}.node.{{ consul_dns_domain }}"
    - key: artifact_store
      value: "file:///etc/marathon/store"

`mantl-chronos`
Chronos is a distributed and fault-tolerant scheduler that runs on top of Apache Mesos that can be used for job orchestration. It supports custom Mesos executors as well as the default command executor. Thus by default, Chronos executes sh (on most systems bash) scripts.
- Dependencies
    - key: zk_hosts
      value: "{{ chronos_zk_connect }}"
    - key: master
      value: "{{ chronos_zk_mesos_master }}"
    - key: hostname
      value: "{{ inventory_hostname }}.node.{{ consul_dns_domain }}"
    - key: http_port
      value: "{{ chronos_port }}"
    - key: mesos_framework_name
      value: "chronos"
    - src: chronos-consul.cfg
      dest: /etc/consul-template/config.d

`mantl-mantllui`
Mantlui consolidates the web UIs of various components in Mantl, including Mesos, Marathon, Chronos, and Consul at a single url on port 80 (http) or 443 (https).
- Dependencies
    - src: mesos/controllers.js
      dest: /usr/share/mesos/webui/master/static/js
    - src: mesos/services.js
      dest: /usr/share/mesos/webui/master/static/js
    - src: mesos/app.js
      dest: /usr/share/mesos/webui/master/static/js
    - src: mesos/index.html
      dest: /usr/share/mesos/webui/master/static
    - src: mesos/pailer.html
      dest: /usr/share/mesos/webui/master/static

`mantl-traefik`
- install traefik from the internet
- copy certs to `/etc/traefik/certs/`
- copy traefik.toml to `/etc/traefik/`
- copy traefik consul service to `/etc/consul/`
- Dependencies
    - mantl-consul

`mantl-distributive`
This is a package that installs distributive, then configures it
- Dependencies
    - mantl-common