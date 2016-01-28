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
            - [docker-cleanup](#docker-cleanup)
            - [nomad](#nomad)
        - [Consul Packages](#consul-packages)
            - [consul](#consul)
            - [consul-ui](#consul-ui)
            - [consul-template](#consul-template)
            - [consul-cli](#consul-cli)
        - [Vault Packages](#vault-packages)
            - [vault](#vault)
            - [vault-mantl](#vault-mantl)
        - [Mantl Packages](#mantl-packages)
            - [mantl-dns](#mantl-dns)
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

#### docker-cleanup

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/docker-cleanup/images/download.svg) ](https://bintray/asteris/mantl-rpm/docker-cleanup/_latestVersion)

[*spec*](packages/docker-cleanup/spec.yml)

A cron.hourly script and a few configuration files to take out the garbage.
Uses `spotify/docker-gc` and `martin/docker-cleanup-volumes` Docker containers in tandem.

First, `spotify/docker-gc` runs, and removes any containers that have been in an exit status for more than an hour.
Spotify's container also supports excluding containers at this step. Two files control this:
`/etc/docker-cleanup/docker-gc-exclude` to match image names and docker hashes, and
`/etc/docker-cleanup/docker-gc-exclude-containers` to match container names. Both of these files have example lines
for your reference.

Second, `martin/docker-cleanup-volumes` removes orphaned Docker volumes, something that removing containers with docker
commands normally does not do. Docker version 1.9 is beginning to address this issue, but this adds support for previous versions.

#### nomad

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/nomad/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/nomad/_latestVersion)

[*spec*](nomad/nomad/spec.yml)

> A Distributed, Highly Available, Datacenter-Aware Scheduler

- [Nomad's Project Page](https://nomadproject.io/)

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

### Mantl Packages

#### mantl-dns

[*spec*](consul/consul-dns/spec.yml)

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/mantl-dns/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/mantl-dns/_latestVersion)

DNS setup with dnsmasq and Consul

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.
