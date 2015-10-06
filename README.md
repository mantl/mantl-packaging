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

[*spec*](packages/generate-certificate/spec.yml)

A script to generate certificates with a number of sensible defaults set.

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.
