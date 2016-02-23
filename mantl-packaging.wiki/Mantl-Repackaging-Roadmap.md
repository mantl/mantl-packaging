# Packaging Roadmap for Mantl

This roadmap is not finalized, and is definitely up for discussion!

### Rationale
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
    - set timezone to UTC -> `user_data: timezone: Etc/UTC`
    - create `/etc/mantl` to hold metadata for state of cluster pre-consul boot
    - j2 template for `/etc/hosts` -> `user_data: resolv_conf: search_domains: [.node.consul]`
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
  - Ansible users tasks should be managed via API or Ansible
  - Ansible ssl tasks
    - copy local path ssl/cacert.pem to remote server /etc/pki/ca-trust/source/anchors/cacert.pem; chown to root
    - notify handler update-ca-trust -> `update-ca-trust`



- logrotate: *this one should be split up and managed by each package that needs it*
- consul-template: *this is in the same boat as mantl-consul*

- logstash: **mantl-logstash**
- nginx: **mantl-nginx**
  - System dependencies
    - nginx
    - mantl-common
  - Ansible main tasks
    - make tls directory -> `mkdir -p /etc/nginx/ssl && chmod 0700 /etc/nginx/ssl`
    - deploy tls files
    - encrypt admin password -> look at mantl PR#1058 for adding passwd to consul
- consul: **mantl-consul**
  - Question: could this be in **mantl-common**?
- dnsmasq: **mantl-dnsmasq**
  - PR#26

*Roles for controls*
- vault: **mantl-vault**

*Roles for edges*
- traefik: **mantl-edge**
  - Notes
    - This will install the traefik binary, and configure the certs, but that depends on how we bootstrap the cluster

### cloud_init user_data.
```yaml
timezone: Etc/UTC
resolv_conf: 
  search_domains: 
    - .node.consul
```

### Addon packages
- calico + etcd ansible roles -> **mantl-calico**
- mesos ansible role with leader/follower configs -> **mantl-mesos-{common?, leader, follower}**
  - common package installs and configures zookeeper?
  - follower package configures node to pull from vault
- marathon ansible role -> **mantl-marathon** package that depends upon **mantl-mesos**
- marathon ansible role -> **mantl-chronos** package that depends upon **mantl-mesos**
- mantlui -> **mantl-ui**
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
- collectd: **mantl-collectd**
  - PR#36
- kubernetes roles