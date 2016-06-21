#!/bin/bash

consulConfigPath=${1:-/etc/consul/acl.json}

# Extract the master token from $consulConfigPath
token=$(jq -r .acl_master_token ${consulConfigPath})
if [ -n "${token}" ]; then
	consul_token="--token=${token}"
fi

if [ "$(curl -s -1 https://localhost:8200/v1/sys/seal-status | jq .sealed )" == "true" ]; then
	for key in $(consul-cli kv read ${consul_token} secure/vault/keys); do
		vault unseal $key
	done
fi

exit 0
