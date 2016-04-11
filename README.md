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
            - [nomad](#nomad)
        - [Consul Packages](#consul-packages)
            - [consul](#consul)
            - [consul-template](#consul-template)
            - [consul-cli](#consul-cli)
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

#### docker-agc

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/docker-gc/images/download.svg) ](https://bintray/asteris/mantl-rpm/docker-gc/_latestVersion)

[*spec*](packages/docker-gc/spec.yml)

Systemd timers that purge unsued docker containers, images, and volumes. 

To check the status of the timers:
`systemctl list-timers`

To run manually:
`systemctl start docker-gc-containers.service`
`systemctl start docker-gc-images.service`
`systemctl start docker-gc-volumes.service`

#### nomad

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/nomad/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/nomad/_latestVersion)

[*spec*](nomad/nomad/spec.yml)

### Consul Packages

#### consul

[*spec*](consul/consul/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/consul/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/consul/_latestVersion)

Packages consul.io with systemd. Check `/etc/sysconfig/consul` for
configuration.

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

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.

