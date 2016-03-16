#!/bin/bash

consul-cli service-register --port 8200 \
    --check-script=/usr/local/bin/vault-health-check.sh \
    --check-interval=15s \
    --id="vault:`uname -n`" \
    vault
