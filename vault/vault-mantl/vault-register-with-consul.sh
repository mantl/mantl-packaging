#!/bin/bash

consul-cli service register --port 8200 \
    --check=script:15s:/usr/local/bin/vault-health-check.sh \
    --id="vault:`uname -n`" \
    vault
