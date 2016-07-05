# Mantl Packaging

This repository contains [Hammer](https://github.com/asteris-llc/hammer) specs
for building generic Mantl utilities.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Mantl Packaging](#mantl-packaging)
	- [Dynamic Configuration](#dynamic-configuration)
		- [Per-node Configuration](#per-node-configuration)
	- [Packages](#packages)
		- [Core](#core)
			- [generate-certificate](#generate-certificate)
			- [traefik](#traefik)
			- [docker-gc](#docker-gc)
			- [mantl-storage-setup](#mantl-storage-setup)
			- [smlr](#smlr)
			- [nomad](#nomad)
			- [zookeepercli](#zookeepercli)
		- [Consul Packages](#consul-packages)
			- [consul](#consul)
			- [consul-ui](#consul-ui)
			- [consul-template](#consul-template)
			- [consul-cli](#consul-cli)
		- [Vault Packages](#vault-packages)
			- [vault](#vault)
			- [vault-mantl](#vault-mantl)
			- [vaultfs](#vaultfs)
		- [Mantl Packages](#mantl-packages)
			- [mantl-dns](#mantl-dns)
		- [Calico packages](#calico-packages)
			- [calico](#calico)
		- [Distributive Packages](#distributive-packages)
			- [distributive](#distributive)
			- [distributive-<package>](#distributive-package)
		- [Mesos Packages](#mesos-packages)
			- [mesos](#mesos)
			- [mesos-master](#mesos-master)
			- [mesos-master-dynamic](#mesos-master-dynamic)
			- [mesos-agent](#mesos-agent)
			- [mesos-agent-dynamic](#mesos-agent-dynamic)
		- [Mesos Frameworks](#mesos-frameworks)
			- [marathon](#marathon)
			- [marathon-dynamic](#marathon-dynamic)
		- [Mantl-Cadvisor Packages](#mantl-cadvisor-packages)
			- [mantl-cadvisor](#mantl-cadvisor)
        - [Beats](#beats)
			- [filebeat](#filebeat)
			- [journalbeat](#journalbeat)
	- [Building](#building)

<!-- markdown-toc end -->

## Dynamic Configuration

Dynamic configuration is performed with [Consul](https://consul.io). The
`{package}-dynamic` entries in this README describe the key spaces they look for
to render configuration to disk. Be aware that most of these daemons need to be
restarted when configuration changes, so account for that when you're changing
keys.

### Per-node Configuration

In addition to the documented keys under each package, you can set per-node
global options for these packages with certain flags. These will be documented
in the config files if not set, but here's a short list:

| Key                               | Description                |
|-----------------------------------|----------------------------|
| `config/nodes/{node}/external_ip` | node's external IP address |
| `config/nodes/{node}/internal_ip` | node's internal IP address |
| `config/nodes/{node}/hostname`    | node's hostname            |

## Packages

### Core

#### generate-certificate

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/generate-certificate/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/generate-certificate/_latestVersion)

[*spec*](packages/generate-certificate/spec.yml)

A script to generate certificates with a number of sensible defaults set.

#### traefik

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/traefik/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/traefik/_latestVersion)

[*spec*](packages/traefik/spec.yml)

> Træfɪk is a modern HTTP reverse proxy and load balancer made to deploy
> microservices with ease. It supports several backends (Docker, Mesos/Marathon,
> Consul, Etcd, Zookeeper, BoltDB, Rest API, file...) to manage its
> configuration automatically and dynamically.

- [Traefik's README](https://github.com/EmileVauge/traefik)

#### docker-gc

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/docker-gc/images/download.svg) ](https://bintray/asteris/mantl-rpm/docker-gc/_latestVersion)

[*spec*](packages/docker-gc/spec.yml)

Systemd timers that purge unsued docker containers, images, and volumes.

To check the status of the timers:
`systemctl list-timers`

To run manually:
`systemctl start docker-gc-containers.service`
`systemctl start docker-gc-images.service`
`systemctl start docker-gc-volumes.service`

#### mantl-storage-setup

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/mantl-storage-setup/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/mantl-storage-setup/_latestVersion)

[*spec*](packages/mantl-storage-setup/spec.yml)

A script that configures LVM on a system based on information in `/etc/mantl/filesystems.d`.

#### smlr

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/smlr/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/smlr/_latestVersion)

[*spec*](packages/smlr/spec.yml)

> smlr waits for service dependencies.

- [smlr's README](https://github.com/asteris-llc/smlr)

#### nomad

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/nomad/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/nomad/_latestVersion)

[*spec*](nomad/nomad/spec.yml)

> A Distributed, Highly Available, Datacenter-Aware Scheduler

- [Nomad's Project Page](https://nomadproject.io/)

#### zookeepercli

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/zookeepercli/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/zookeepercli/_latestVersion)

[*spec*](packages/zookeepercli/spec.yml)

> Zookeepercli is a simple, lightweight, dependable CLI for ZooKeeper

- [zookeepercli's README](https://github.com/outbrain/zookeepercli)


### Consul Packages

#### consul

[*spec*](consul/consul/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/consul/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/consul/_latestVersion)

Packages consul.io with systemd. Check `/etc/sysconfig/consul` for
configuration.

#### consul-ui

[*spec*](consul/consul-ui/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/consul-ui/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/consul-ui/_latestVersion)

Standalone web UI for Consul

#### consul-template

[*spec*](consul/consul-template/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/consul-template/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/consul-template/_latestVersion)

Packages [consul-template](https://github.com/hashicorp/consul-template) with
systemd. Check `/etc/sysconfig/consul-template` for configuration.

#### consul-cli

[*spec*](consul/consul-cli/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/consul-cli/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/consul-cli/_latestVersion)

Packages [consul-cli](https://github.com/CiscoCloud/consul-cli) with the
currently released version.

> A Distributed, Highly Available, Datacenter-Aware Scheduler

- [Nomad's Project Page](https://nomadproject.io/)

### Vault Packages

#### vault

[*spec*](vault/vault/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/vault/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/vault/_latestVersion)

Packages vault.io with systemd. Check `/etc/sysconfig/vault` for
configuration.

#### vault-mantl

[*spec*](vault/vault-mantl/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/vault-mantl/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/vault-mantl/_latestVersion)

Packages mantl.io specific scripts for Vault.

| Script                          | Description                               |
|---------------------------------|-------------------------------------------|
| `vault-bootstrap.sh`            | Initialize vault and store keys in Consul |
| `vault-health-check.sh`         | Consul health check script for Vault      |
| `vault-register-with-consul.sh` | Register the Vault service with Consul    |
| `vault-unseal.sh`               | Read tokens from Consul and unlock Vault  |

#### vaultfs

[*spec*](vault/vault-mantl/spec.yml)

Packages vaultfs with systemd. Check `/etc/sysconfig/vault` for
configuration.

### Mantl Packages

#### mantl-dns

[*spec*](consul/consul-dns/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/mantl-dns/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/mantl-dns/_latestVersion)

DNS setup with dnsmasq and Consul


### Calico packages

#### calico

[*spec*](calico/calico/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/calico/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/calico/_latestVersion)

### Distributive Packages

#### distributive

Package containing the Distributive binary.

#### distributive-<package>

Distributive checklists for various Mantl components are included in
[the `distributive` directory](distributive).

### Mesos Packages

#### mesos

[*spec*](core/mesos/spec.yml)

The base Mesos package, including bindings. There is no configuration in this
package.

#### mesos-master

[*spec*](core/mesos-master/spec.yml)

The mesos master process. This is a configuration-only package, and will provide
the `mesos-master` service by depending on `mesos`. `mesos-master` is configured
via environment variables in `/etc/sysconfig/mesos-master`.

#### mesos-master-dynamic

[*spec*](core/mesos-master-dynamic/spec.yml)

Makes [mesos-master](#mesos-master) dynamic by populating it with
[consul-template](https://github.com/hashicorp/consul-template)
([spec](https://github.com/asteris-llc/consul-packaging/blob/master/packaging/consul-template/spec.yml)).

Available configuration:

| Key | Description | Default |
|-----|-------------|---------|
| `config/mesos/agents/{node}/principal` and `config/mesos/agents/{node}/secret` | agent principal(s) and secret(s), respectively | not set |
| `config/mesos/frameworks/{name}/principal` and `config/mesos/frameworks/{name}/secret` | framework principal(s) and secret(s), respectively | not set |
| `config/mesos/master/extra_options` | extra command-line options to pass to `mesos-master` | not set |
| `config/mesos/master/firewall_rules` | see [Mesos docs](http://mesos.apache.org/documentation/latest/configuration/) | `{}` |
| `config/mesos/master/nodes/{node}/options` | same as options, but per-node | not set |
| `config/mesos/master/options` | any key from the [configuration options](http://mesos.apache.org/documentation/latest/configuration/). Value will be uppercased to become an environment variable. | not set |

This package assumes that authentication will be done globally, and so will not
pay attention to unsetting the authentication per-node; it must be done
globally. It also pays attention to both the `authenticate_slaves` and
`authenticate_agents` flags for backwards compatibility.

This package also uses `internal_ip`, `external_ip`, and `hostname` from the
[Per-node Configuration](#per-node-configuration). Do note that you can override
the values set in this way in the configuration by overriding them in
`config/mesos/master/nodes/{node}/options`.

#### mesos-agent

[*spec*](core/mesos-agent/spec.yml)

The mesos agent process (formerly `mesos-slave`). This package name is being
changed in advance of the upstream change to `mesos-agent`, and will call the
appropriate binaries for the version of Mesos provided. This is a
configuration-only package, and will provide the `mesos-agent` service by
depending on `mesos`. `mesos-agent` is configured via environment variables in
`/etc/sysconfig/mesos-agent`.

#### mesos-agent-dynamic

[*spec*](core/mesos-agent-dynamic/spec.yml)

Makes [mesos-agent](#mesos-agent) dynamic by populating it with
[consul-template](https://github.com/hashicorp/consul-template)
([spec](https://github.com/asteris-llc/consul-packaging/blob/master/packaging/consul-template/spec.yml)).

Available configuration:

| Key | Description | Default |
|-----|-------------|---------|
| `config/mesos/agent/extra_options` | extra command-line options to pass to `mesos-agent` | not set |
| `config/mesos/agent/firewall_rules` | see [Mesos docs](http://mesos.apache.org/documentation/latest/configuration/) | `{}` |
| `config/mesos/agent/nodes/{node}/options` | same as options, but per-node | not set |
| `config/mesos/agent/options` | any key from the [configuration options](http://mesos.apache.org/documentation/latest/configuration/). Value will be uppercased to become an environment variable. | not set |
| `config/mesos/agents/{node}/principal` and `config/mesos/agents/{node}/secret` | agent principal and secret, respectively. This uses the value of the Consul node to determine the key. | not set |

Authentication for this package will be enabled if the principal and secret are
both set.

This package also uses `internal_ip` and `hostname` from the
[Per-node Configuration](#per-node-configuration). Do note that you can override
the values set in this way in the configuration by overriding them in
`config/mesos/agent/nodes/{node}/options`.

### Mesos Frameworks

#### marathon

[*spec*](frameworks/marathon/spec.yml)

[Marathon](http://mesosphere.github.io/marathon), a cluster-wide init and
control system for services in cgroups or Docker containers. Marathon can be
controlled with environment variables in `/etc/sysconfig/marathon`, the
available options are documented in the
[Marathon command-line flags documentation](http://mesosphere.github.io/marathon/docs/command-line-flags.html).

#### marathon-dynamic

[*spec*](frameworks/marathon-dynamic/spec.yml)

Makes [marathon](#marathon) dynamic by populating it with
[consul-template](https://github.com/hashicorp/consul-template)
([spec](https://github.com/asteris-llc/consul-packaging/blob/master/packaging/consul-template/spec.yml)).

Available configuration:

| Key | Description |
|-----|-------------|
| `config/marathon/options/{key}` | any key from the [command line flags](http://mesosphere.github.io/marathon/docs/command-line-flags.html). Value will be uppercased to become an environment variable. |
| `config/marathon/hosts/{node}/options/{key}` | the same as `marathon/config/{key}`, but the flags will only be applied to the specified node |

### Mantl-Cadvisor Packages

#### mantl-cadvisor

[*spec*](mantl-cadvisor/mantl-cadvisor/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/mantl-cadvisor/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/mantl-cadvisor/_latestVersion)

cAdvisor customized for Mantl clusters

### Beats

#### filebeat

[*spec*](beats/filebeat/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/filebeat/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/filebeat/_latestVersion)

#### journalbeat

[*spec*](beats/journalbeat/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/journalbeat/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/journalbeat/_latestVersion)

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.

If you add a new package, be sure to run `make scripts/paths` so that it will be
picked up by CI.
