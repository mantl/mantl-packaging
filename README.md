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
            - [traefik-dynamic](#traefik-dynamic)
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

#### traefik-dynamic

[ ![Download](https://api.bintray.com/packages/asteris/mantl-rpm/traefik-dynamic/images/download.svg) ](https://bintray.com/asteris/mantl-rpm/traefik-dynamic/_latestVersion)

[*spec*](packages/traefik-dynamic/spec.yml)

A dynamically-templated version of træfɪk using consul-template.

Here are the keys you can use:

| Key | Description | Default |
|-----|-------------|---------|
| `config/traefik/port` | global listening port | `:80` |
| `config/traefik/gracetimeout` | graceful restart timeout | `10` |
| `config/traefik/logs` | location of the traefik log file on disk | not set |
| `config/traefik/access` | location of the traefik access log file on disk | not set|
| `config/traefik/loglevel` | logging level for global logging | `ERROR` |
| `config/traefik/certfile` | cert file for HTTPS communication | not set |
| `config/traefik/keyfile` | key file for HTTPS communication | not set |
| `config/traefik/web/enable` | if present, enable the web management interface | not enabled |
| `config/traefik/web/address` | address to listen on for management interface | `:8080` |
| `config/traefik/web/certfile` | cert file for HTTPS communication | not set |
| `config/traefik/web/keyfile` | key file for HTTPS communication | not set |
| `config/traefik/boltdb/enable` | if present, enable the boltdb backend | not enabled |
| `config/traefik/boltdb/endpoint` | location on disk of boltdb database | `/etc/traefik/traefik.db` |
| `config/traefik/boltdb/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/boltdb/prefix` | key prefix | `traefik` |
| `config/traefik/consul/enable` | if present, enable the consul backend | not enabled |
| `config/traefik/consul/endpoint` | consul endpoint to connect to | `127.0.0.1:8500` |
| `config/traefik/consul/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/consul/prefix` | key prefix | `traefik` |
| `config/traefik/docker/enable` | if present, enable the docker backend | not enabled |
| `config/traefik/docker/endpoint` | docker endpoint to connect to | `unix:///var/run/docker.sock` |
| `config/traefik/docker/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/docker/domain` | domain to route traffic to | `docker.localhost` |
| `config/traefik/etcd/enable` | if present, enable the etcd backend | not enabled |
| `config/traefik/etcd/endpoint` | etcd endpoint to connect to | `127.0.0.1:4000` |
| `config/traefik/etcd/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/etcd/prefix` | key prefix | `/traefik` |
| `config/traefik/marathon/enable` | if present, enable the marathon backend | not enabled |
| `config/traefik/marathon/endpoint` | marathon endpoint to connect to | `http://127.0.0.1:8000` |
| `config/traefik/marathon/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/marathon/domain` | domain to route traffic to | `marathon.localhost` |
| `config/traefik/zookeeper/enable` | if present, enable the etcd backend | not enabled |
| `config/traefik/zookeeper/endpoint` | etcd endpoint to connect to | `127.0.0.1:2181` |
| `config/traefik/zookeeper/watch` | watch for changes (`true` or `false`) | `true` |
| `config/traefik/zookeeper/prefix` | key prefix | `/traefik` |

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.
