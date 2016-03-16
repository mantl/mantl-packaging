#!/bin/bash

vault_url="https://localhost:8200"

systemctl is-active vault >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Vault is not running"
	exit 2
fi

if [ "$( curl -s -1 $vault_url/v1/sys/init | jq .initialized )" != "true" ]; then
	echo "Vault not initialized"
	exit 2
fi

if [ "$( curl -s -1 $vault_url/v1/sys/seal-status | jq .sealed )" == "true" ]; then
	echo "Vault is sealed"
	exit 2
fi

echo "Vault is running"

exit 0

