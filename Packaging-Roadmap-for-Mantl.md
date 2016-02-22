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

#### Ansible roles -> New Packages
Here is the list from the `terraform.sample.yml` ansible playbook. For each role that
we can port to a package, put the package name after it, and list the package description
below, or make a note. I hope that the ad-hoc formatting here makes sense.

I'm not going to include any package upgrade logic here, either for yum or pip.
We will let the user/packages decide what versions to use

Another assumption here is that each of these packages are going to have
distributive check files associated with them. As of right now, those are in
the distributive-{component} packages.

*Roles for all hosts*
- common: **mantl-common**
  - System Dependencies
    - python-pip
    - httpd-tools
    - nc
    - openssh
    - policycoreutils-python
    - epel-release
    - unzip
  - Ansible defaults: selinux with permissive policy and central configuration
  - Ansible handlers: update-ca-trust -> run `update-ca-trust` cmd in package script when needed
  - Ansible main tasks
    - set timezone to UTC -> `ln -sf /etc/localtime /usr/share/zoneinfo/Etc/UTC`
    - create `/etc/mantl` to hold metadata for state of cluster pre-consul boot
    - j2 template for `/etc/hosts` -> consul template for `/etc/hosts`
    - install distributive from ciscocloud's bintray -> separate package (**mantl-distributive**)?
    - disable requiretty in sudoers -> sed 's/^.+requiretty$/# Defaults requiretty/' /etc/sudoers #but only last entry
    - set selinux policy based on ansible defaults 
    - disable firewalld -> here is a partial go implementation:
```
package main
import (
  "fmt"
  "log"
  "os/exec"
)

func main () {
  // disable firewalld
  out, err := exec.Command("systemctl disable firewalld").Output()
  if err != nil{
    log.Fatal(err)
  }

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
```
  - Ansible users tasks
    - configure members of wheel group for passwordless sudo -> `sed 's/^%wheel/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers`
    - create enabled os users, based on `users` ansible var ([docs](http://mantl.readthedocs.org/en/latest/getting_started/ssh_users.html))
    - set ssh key for `users`
    - delete disabled `users`
  - Ansible ssl tasks
    - copy local path ssl/cacert.pem to remote server /etc/pki/ca-trust/source/anchors/cacert.pem; chown to root
    - notify handler update-ca-trust -> `update-ca-trust`

- lvm: **mantl-lvm**
  - System Dependencies
    - mantl-common
    - device-mapper-libs
    - lvm2
  - Ansible facts
    - defaults: lvm_volume_group_name=mantl, lvm_physical_device= different things depending upon provider
    - volume groups list -> `vgscan`
  - Ansible volume tasks when volume has not been created
    - create volume group, based on ansib
    - enable lvmetad service -> `systemctl enable lvm2-lvmetad 2>/dev/null && systemctl restart lvm2-lvmetad`
  - Ansible main tasks: set group name to blank if physical device is blank

- collectd: **mantl-collectd**
  - PR#36
- logrotate: *this one should be split up and managed by each package that needs it*
- consul-template: *this is in the same boat as mantl-consul*
- docker: **mantl-docker**
  - Notes
    - needs logrotate config from ansible role
    - there's a bunch of stuff here for LVM.
      - We could create separate package for it **mantl-docker-lvm**
      - Or, we could include it in **mantl-lvm**
  - same goes for the collectd docker plugin
  - System Dependencies
    - docker
    - docker-selinux
    - mantl-common
- logstash: **mantl-logstash**
- nginx: **mantl-nginx**
- consul: **mantl-consul**
  - Notes
    - This is a central package for mantl, especially for repackaging. I
      propose that this package installs consul, consul-template, and
      consul-ui, and inits the cluster. In fact, could this be in the **mantl-common**?
- dnsmasq: **mantl-dnsmasq**
  - PR#26

*Roles for workers*
- mesos: *Secrets should be managed by vault before this is a package*
  - needs logrotate config from ansible role

*Roles for controls*
- vault: **mantl-vault**
- zookeeper: **mantl-zookeeper**
  - needs logrotate
- mesos: **mantl-mesos**
  - needs logrotate
- marathon: **mantl-marathon**
- chronos: **mantl-chronos**
- mantlui: **mantl-mantlui**

*Roles for edges*
- traefik: **mantl-traefik**

NOTES:

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

`mantl-ui`
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
