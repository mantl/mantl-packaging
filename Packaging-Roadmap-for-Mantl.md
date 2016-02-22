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

`mantl-collectd`: pushed to asteris-lc/mantl-packaging

collectd/files/collectd_docker_plugin.pp

collectd/handlers/main.yml
    // restart collectd on hosts
    solutions:
       sudo systemctl restart mantl-collectd

collectd/tasks/main.yml
    // install collectd packages collectd and     libsemanage-python(manage selinux settings here)
    package solutions:
     sudo yum -y install collectd libsemanage-python

     line 14
     // create collectd plugin directory /usr/share/collecd/plugins and set permissions to 0755
     solutions:
        sudo mkdir /usr/share/collectd/plugins
        chmod 0755 /usr/share/collectd/plugins

      line 23
      // copies collectd.conf.j2 to /etc/collectd.conf
      // restart collectd
      packaging solutions: .j2 will be converted to new format and be copied to etc

      line 34
      // authorize collectd to make tcp connections
      // sudo
      // when selinux(ansible) status is enabled and the mode is enforcing
          // SELinux boolean named collectd_tcp_network_connect is set to yes
          // collectd_tcp_network_connect should survive a reboot
      packaging solutions:
          setsebool -P collectd_tcp_network_connect 1

      line 41
      // check if collectd is authorized to connect to docker
      // sudo
      // when selinux(ansible) status is enabled and the mode is enforcing
      // run shell command on node: semodule -l(lists policy modules on a system)
          // store results in variable semodule_list
          // ansible doesn't report change status (there is already either a return code or output that makes this obvious)
          // probably the same with failure, ansible doesn't report failure
      packaging solutions(combine with 51 and 58):
          # list policy modules on the system
          semodule -l
          # if the above output is defined and collectd_docker_plugin does not exist, copy plugin.pp and set permissions

          cp collectd_docker_plugin.pp /tmp/collectd_docker_plugin.pp && chmod 0600
          #install the plugin
          semodule -i /tmp/collectd_docker_plugin.pp
              #after-remove section: remove/disable this plugin

      line 51
      // copy collectd selinux docker policy
      // sudo copy plugin.pp and set the mode to 0600
      // do this when "semodule_list.stdout is defined and
         semodule_list.stdout.find('collectd_docker_plugin') == -1"
      packaging solutions(see 41):
        cp collectd_docker_plugin.pp /tmp/collectd_docker_plugin.pp && chmod 0600
        // when  "semodule_list.stdout is defined and semodule_list.stdout.find('collectd_docker_plugin') == -1"

      line 58
      // authorize collectd to connect to docker
      semodule -i /tmp/collectd_docker_plugin.pp
      // when  "semodule_list.stdout is defined and semodule_list.stdout.find('collectd_docker_plugin') == -1"
      packaging solutions:(see 41)

      line 65
      // start collectd on boot(enable a service)
      packaging solutions:
      systemctl enable collectd 2>/dev/null

    templates/collectd.conf.j2
    packaging solutions:
       // convert format


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
          packaging solutions: firewalld-cmd --state; echo $?       252=NOT_RUNNING
            // disable firwalld (sudo systemctl disable firewalld)
            // run a script that checks if it is disabled
                ./firewalld_script
            // script that checks that it is disabled(ok, go was fun but come up with bash commands instead)
              #!/go/bin
              package main
              import (
                  "fmt"
                  "log"
                  "os/exec"
              )

              func main () {
                  // check state of firewalld
                  out, err := exec.Command("firewalld-cmd --state").Output()
                  if err != nil{
                    log.Fatal(err)
                  }
                  // if the state is NOT not running, disable has failed
                  if out != not running{
                    log.Fatal(err)
                    fmt.println ("Firewalld is not disabled.")
                  }      
              }

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
               sudo yum -y update pip setuptools

        lines 65-71
            // sudo
            // install distributive from bintray:
                //https://bintray.com/artifact/download/ciscocloud/rpm/distributive-0.2.1-5.el7.centos.x86_64.rpm
            // tag is distributive
            // use bintray.sh to install

        lines 73-80
            lineinfile-ensure that a particular line is in a file, or replace an existing line using a back-referenced regular expression
            // sudo
            // disable requiretty in sudoers
                // look for the regular expression ^.+requiretty$ in every line of the file, /etc/sudoers. This regular                         expression should be in this file.
                // replace the last instance of this regular expression with "# Defaults requiretty"
            -packaging solutions: write a search and replace script that replaces the last instance      of the string

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

`mantl-docker`
  /docker/defaults/main.yml

`mantl-dnsmasq`: already completed on asteris-lc/mantl-packaging/mantl/mantl-dns
      /files/distributive-dnsmasq-check.json

      /handlers/main.yml
        - run 2 commands on nodes
        - sudo systemctl restart NetworkManager
        - sudo systemctl restart dnsmasq
        packaging solutions:
          ansible all -i plugins/inventory/terraform.py -a "sudo systemctl restart NetworkManager"
          ansible all -i plugins/inventory/terraform.py -a "sudo systemctl restart dnsmasq"

      /tasks/distributive.yml
        - create directory (and subdirectories)at destination /etc/consul when consul_dc_group is defined
        - chmod 0700
        - tags are consul, distributive, dnsmasq
        packaging solutions:
          // export consul_dc_group variable?
          #!/bin/bash
          echo ${consul_dc_group:? "consul_dc_group is not defined"}
          sudo mkdir /etc/consul/
          sudo chmod 0700 /etc/consul

        line 16
        - sudo
        - create a symlink to distributive dnsmasq checklist from
          /usr/share/distributive/dnsmasq.json to /etc/distributive.d/dnsmasq.json
        - tags are consul, distributive, dnsmasq
        packaging solutions:
          ln -s /etc/distributive.d/dnsmasq.json /usr/share/distributive/dnsmasq.json

        line 27
        // register distributive tests with consul
        - sudo
        - copy distributive-dnsmasq-check.json to /etc/consul/ when consul_dc_group is defined
        - reload consul
        - tags are consul, distributive, dnsmasq
        packaging solutions:
          // export consul_dc_group variable?
          #!/bin/bash
          echo ${consul_dc_group:? "consul_dc_group is not defined"}
          cp distributive-dnsmasq-check.json /etc/consul/ (check which directory the json file is in)  

      /tasks/main.yml
        - sudo yum install latest versions of packages dnsmasq, bind-utils, NetworkManager
        - tags are dnsmasq and bootstrap
        packaging solutions:
            sudo yum -y install dnsmasq bind-utils NetworkManager

        line 15
        //collect nameservers
        - run shell command on node:  "sudo cat /etc/resolv.conf | grep -i '^nameserver' | cut -d ' ' -f2"
        - the output of the above command should be set to variable "nameservers_output"
        - tag is dnsmasq
        packaging solutions:
           ansible all -i plugins/inventory/terraform.py -a "nameservers_output = $(sudo cat /etc/resolv.conf | grep -i '^nameserver' | cut -d ' ' -f2)"

        line 22
        - run shell command on node: "cat /etc/resolv.conf | grep -i '^search' | cut -d ' ' -f2- | tr ' ' '\n'"
        - store output in variable "dns_search_list_output"
        - tag is dnsmasq
        packaging solutions:
             ansible all -i plugins/inventory/terraform.py -a "dns_search_list_output = $(sudo cat /etc/resolv.conf | grep -i '^search' | cut -d ' ' -f2- | tr ' ' '\n')"

        line 29
        // set nameservers
        // establish key-value pairs
          - nameservers:  "{{ nameservers_output.stdout_lines }}"
        // tag dnsmasq  
        packaging solutions: call a python script keyvalue.py(set permissions first). Give the function argument nameservers_output (can you pass arguments to scripts?)
          // iterate through nameservers_output
          // set key-value pairs(nameservers: nameservers_output.stdout_lines)

        line 35
        // set dns search list(key-value pair)
          - domain_search_list: "{{ dns_search_list_output.stdout_lines }}"
        // tag is dnsmasq
        packaging solutions: call keyvalue.py

        line 41
        // ensure dnsmasq.d directory exists
          - sudo create directory and subdirectories(if they are there): /etc/NetworkManager/dnsmasq.d
        // tag is dnsmasq
        packaging solutions:
          sudo mkdir /etc/NetworkManager/dnsmasq.d

        line 49
        // configure dnsmasq for consul
          // when consul_dc_group is defined
              // sudo
              // copy 10-consul to /etc/dnsmasq.d/10-consul
              // chmod 0755
              // restart dnsmasq
          // tag is dnsmasq
          packaging solutions:
             sudo cp 10-consul /etc/dnsmasq.d
             sudo chmod 0755 /etc/dnsmasq.d/10-consul
             sudo systemctl restart dnsmasq

        line 61
        // configure dnsmasq for Kubernetes
          // when cluster_name is defined
            // sudo
            // copy 20-kubernetes to /etc/dnsmasq.d/20-kubernetes
            // chmod 0755
            // restart dnsmasq
          // tag is dnsmasq
          packaging solutions:
            sudo cp 20-kubernetes /etc/dnsmasq.d/20-kubernetes
            sudo chmod 0755
            sudo systemctl restart dnsmasq

        line 73
        // sudo
        // start dnsmasq on boot if necessary
        // dnsmasq is tag

        line 82
        // configure networkmanager for dnsmasq
        // sudo
        // In the file: /etc/NetworkManager/NetworkManager.conf
        // Insert "dns=none" after the reg expression: "^\\[main\\]$"
        // restart networkmanager
        // tag is dnsmasq
        packaging solutions:


        line 93
        // List network-scripts which need fixup
        // sudo
        // run shell command "find /etc/sysconfig/network-scripts -name 'ifcfg-*'"
        .*// set the above output to variable "list_of_network_scripts"
        packaging solutions:
            // combine line 93 and 98 by doing find and executing a sed statement(Is the variable list_of_network_scripts needed anywhere else?)
            sudo find /etc/sysconfig/network-scripts -name 'ifcfg-*' -exec sed -i '' 's/^PEERDNS=.*/PEERDNS=no/' \{\} \;
              //   errors  sed: can't read s/^PEERDNS=.*/PEERDNS=no/: No such file or directory
                  sed: can't read s/^PEERDNS=.*/PEERDNS=no/: No such file or directory


        line 98
        // fixing PEERDNS in network-scripts
        // loop: for each in the list_of_network_scripts; do ...the following using ${x} ... ; done
            // sudo
            // modify file: "{{ item }}"
            // look for regular expression ^PEERDNS=.*'
           .*// replace regular expression with "PEERDNS=no"
        // restart networkmanager
        // tag is dnsmasq
        packaging solutions:
          //combined with line 93


        line 110
        // sudo
        // copy resolv.conf.j2 (format will have to be changed) to /etc/resolv.conf
        // chmod 0644
        // tag is dnsmasq

        - meta: flush_handlers
          // dependency of flush_handlers contained in role file meta

        - run play distributive.yml(run this subset rather than all of main.yml)

    10-consul
    20-kubernetes
    90-base
    resolv.conf.j2(needs new format)

`mantl-logrotate` : finished and pushed to asteris-lc/mantlpackaging
  tasks/main.yml
    // set logrotate interval to daily
    // in file /etc/logrotate.conf
    // look for reg expression '^weekly'
    // replace last matching line of reg expression with "daily"
    packaging solutions:
      sed 's/\(.*\)^weekly/daily/' /etc/logrotate.conf

    .*// set logrotate retention period to 7 days
    // in file /etc/logrotate.conf
    // replace last matching line of reg expression '^rotate 4' with "rotate 7"
    packaging solutions:
      sed 's/\(.*\)^rotate 4/\rotate 7/' /etc/logrotate.conf

    .*// copy component logrotate configurations
    // when mesos=true docker=true and in zookeeper role == 'control'
        // copy component to logrotate configurations
            /etc/logrotate/component
        // set mode to 0644
    packaging solutions:
    // call on script: when mesos and docker are installed on all nodes and zookeeper is on leader nodes, copy components to logrotate
        script:
           #!/bin/bash
           for component in "mesos" "docker" "zookeeper"; do
               systemctl status component
                  if[ $? == 0 ]; then
                      cp component /etc/logrotate/
                      chmod 0644 /etc/logrotate/component
                  else
                      echo component not active
                  fi
            done

    // create component archives
        // same conditions as above
        // copy components to archives
            // /var/log/component/archive
    packaging solutions:
    // call on script: when mesos and docker are installed on all nodes and zookeeper is on leader nodes, copy components to archive
    script:
       #!/bin/bash
       for component in "mesos" "docker" "zookeeper"; do
           systemctl status component
              if[ $? == 0 ]; then
                  sudo cp component /var/log/component/archive
                  sudo chmod 0644 /var/log/component/archive
              else
                  echo component not active
              fi
        done

 + 3 template files


`mantl-lvm`
- This lvm role optionally creates an LVM Volume group
Install required software and tools.
Enable lvmetad daemon.
Create volume group and add provided extra block device to it as physical volume.
Register fact with name of created volume group.
- create volume group, and save the in `etc/mantl`
- enable lvmetad service
- Dependencies
    - mantl-common
    - device-mapper-libs
    - lvm2

  roles/lvm/defaults/main.yml
  // defines variables lvm_volume_group_name and lvm_physical_device
  solutions: part of spec file

roles/lvm/tasks/main.yml
// include volume.yml when lvm_physical_device is not null
// set volume_group_name to null when lvm_physical_device is null
solutions:
  //if lvm_physical_device != ""
      define variables lvm_volume_group_name and lvm_physical_device
  //else volume_group_name = ""

roles/lvm/tasks/volume.yml
  line 2
  // sudo yum install latest device-mapper-libs
  // tags are docker,bootstrap,lvm2
  solutions:
    // part of depends section

  line 13
  // update lvg ansible modules
  // run on local host
  // run one time on the one host
  // put ansible file (from url) in {{ playbook_dir }}/library/lvg.py
  // url: https://raw.githubusercontent.com/ansible/ansible-modules-extras/02b68be09dca9760a761d4147f76cfc940c41cba/system/lvg.py
  // tag is docker
  solutions: delete, any replacement needed?

 line 22
  // sudo yum install latest lvm2 tools
  // tags are docker, bootstrap, lvm
  solutions: part of depends section

 line 32
  // sudo list volume groups with command vgscan and put output in variable volume_groups
  // tags are docker and lvm
  solutions: volume_groups=$(vgscan)

  line 40
  // create volume group
  // volume group name(from tasks/main.yml) and comma separated devices to use as physical devices
  // these are created when there is nothing in them

  line 50
  // enable lvmetad service
  // start lvm2-lvmetad on boot
  // tags are docker and lvm
  packaging solutions:
    systemctl enable lvm2-lvmetad 2>/dev/null
    systemctl restart lvm2-lvmetad

  line 60
  // save lvm_volume_group_name as variable called volume_group_name
  // tag is lvm
  solutions: volume_group_name=$(lvm_volume_group_name)

`mantl-nginx`
  create tls directory
  solution:
    sudo mkdir -p /etc/nginx/ssl && chmod 0700

  deploy tls files
  solution(check to see if this works):
    sudo cp -p ssl/certs/nginx.cert.pem /etc/nginx/ssl/nginx.cert && chmod 0444 /etc/nginx/ssl/nginx.cert
    sudo cp -p ssl/private/nginx.key.pem /etc/nginx/ssl/nginx.key && chmod 0444 /etc/nginx/ssl/nginx.key

  encrypt admin password
    // run shell command: htpasswd -Bnb admin {{ nginx_admin_password | quote }} | cut -f 2 -d ':'
    // store in variable nginx_admin_password_encrypted

  set admin password variable
    // sets nginx_admin_password_encrypted as the stdout of this variable to survive between plays of ansible run

    solutions: the password has to be different for every install, this step may need to be done outside the context of a package.

`mantl-collectd`: finished

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

`mantl-etcd`
  defaults/main.yml
    // variables

  files/etcd-service-start.sh
  files/etc-service.json

  handlers/main.yml
    // sudo systemctl restart etcd
    // sudo systmectl restart skydns

  meta/main.yml
    // dependent on handlers role

  tasks/main.yml
    // sudo install version of etcd specified in variables

    10// generate systemd environment file
      // copy /etcd.conf.j2  /etc/etcd.conf
      // chmod 0644
      // reload systemd
      // restart etcd
      solutions:
        sudo cp -p templates/etcd.conf /etc/etcd.conf
        sudo chmod 0644 /etc/etcd.conf
        sudo systemctl daemon-reload
        sudo systemctl restart etcd

      24// install etcd launch script
      // sudo
      // copy etcd-service-start.sh to /usr/local/bin
      // chmod 0755
      //restart etcd
      solutions:
        sudo cp etcd-service-start.sh /usr/local/bin/
        sudo chmod 0755 /usr/local/bin/etcd-service-start.sh
        sudo systemctl restart etcd

      35// create directory /etc/systemd/system/etcd.service.d
      solutions:
        sudo mkdir -p /etc/systemd/system/etcd.service.d

      43// create local etcd service override
          // gives the config these contents
            //   [Service]
      ExecStart=
      ExecStart=/usr/local/bin/etcd-service-start.sh
      to
      /etc/systemd/system/etcd.service.d/local.conf

      56// install consul check script
        // when consul_dc_group is defined
          // copy consul-check-etcd-member to /usr/local/bin
          // chmod 0755
        solutions:
          //when consul_dc_group is defined
          sudo cp consul-check-etcd-member /usr/local/bin/
          chmod 0755 /usr/local/bin/consul-check-etcd-member

      66// when consul_dc_group is defined
        // sudo copy etcd-service.json to /etc/consul
        // reload consul
        solutions:
          // when consul_dc_group is defined
          sudo cp etcd-service.json /etc/consul/
          sudo systemctl reload consul

      77// enable and start etcd service
      solutions:
      sudo systemctl enable etcd 2>/dev/null
      sudo systemctl start etcd

      86 // when dns_setup is defined include skydns.yml

      89 // meta: flush_handlers

    /tasks/skydns.yml
      // sudo
        // cp skydns.service.j2 /usr/lib/systemd/system/skydns.service
        // chmod 0644
        // reload systemd
        // restart skydns
      solutions:
        sudo cp skydns.service /usr/lib/systemd/system/skydns.service
        sudo chmod 0644 /usr/lib/systemd/system/skydns.service
        sudo systemctl daemon-reload
        sudo systemctl restart skydns

      // sudo
        // cp skydns.env.j2 /etc/default/skydns.env
        // mode 0644?
        solutions:
          sudo cp skydns.env /etc/default/
          sudo chmod 0644 /etc/default/skydns.env

    /templates/
      // configurations


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

   traefik/defaults/main.yml
    // defines traefik variables

   traefik/files/traefik-consul.json
    // json config

    traefik/handlers/main.yml
      // sudo systemctl reload consul
      // sudo systemctl restart traefik

    traefik/tasks/main.yml
      // uses traefik variables to download traefik-consul
        // download traefik_download
        // run checksum(traefik_sha256-checksum)
        // install in /root/traefik_filename

      // sudo install traefik in /root/traefik_filename
        // state is present

      // make certificate directory /etc/traefik/certs
      solutions:
        sudo mkdir /etc/traefik/certs

      // copy ssl/certs/traefik-admin.cert.pem  ssl/private/traefik-admin.key.pem  to the certs directory
      solutions:
        sudo cp -p ssl/certs/traefik-admin.cert.pem /etc/traefik/certs/
        sudo cp -p ssl/private/traefik-admin.key.pem /etc/traefik/certs/

      // configure traefik
          // copy traefik.toml.j2 to /etc/traefik/traefik.toml
          // backup file
          // permission 0644
          // restart traefik
        solutions:
          sudo cp traefik.toml /etc/traefik/
          sudo chmod 0644 /etc/traefik/traefik.toml


      // generate traefik consul service
        // sudo copy traefik-consul.json to /etc/consul/traefik.json
        // reload consul
        solutions:
          sudo cp traefik-consul.json /etc/consul/traefik.json
          sudo systemctl reload consul

      roles/traefik/templates
      // traefik.toml.j2

`mantl-distributive`
This is a package that installs distributive, then configures it
- Dependencies
    - mantl-common
