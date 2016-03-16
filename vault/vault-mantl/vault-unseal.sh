#!/bin/bash

# CONSTANTS
#
SECURE_TOKEN_PATH="/etc/default/consul_secure.env"

# Variables
#
token="$1"

if [ -z "${token}" -a -f ${SECURE_TOKEN_PATH} ]; then
	source ${SECURE_TOKEN_PATH}
	token=${SECURE_TOKEN}
fi

if [ "$(curl -s -1 https://localhost:8200/v1/sys/seal-status | jq .sealed )" == "true" ]; then
	for key in $(consul-cli kv-read --token=${token} secure/vault/keys); do
		vault unseal $key
	done
fi

exit 0
