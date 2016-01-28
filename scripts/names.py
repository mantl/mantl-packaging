#!/usr/bin/env python
import sys
from subprocess import Popen, PIPE

prefixes = {
    'consul/consul-cli': 'consul-cli',
    'consul/consul': 'consul',
    'consul/consul-ui': 'consul-ui',
    'consul/consul-template': 'consul-template',
    'nomad/nomad': 'nomad',
    'packages/docker-cleanup': 'docker-cleanup',
    'packages/generate-certificate': 'generate-certificate',
    'packages/traefik': 'traefik',
    'vault/vault': 'vault',
    'vault/vault-mantl': 'vault-mantl',
    'mantl/mantl-dns': 'mantl-dns',
}

def diffed_files(a, b):
    """get the diffed files between two commits"""
    git = Popen(["git", "diff", "--name-only", a, b], stdout=PIPE, stderr=PIPE)
    out, err = git.communicate()

    return out.split()

def main(args):
    names = set()
    for fname in diffed_files(*args):
        for prefix, package in prefixes.items():
            if fname.startswith(prefix):
                names.add(package)

    print ' '.join(names)

    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
