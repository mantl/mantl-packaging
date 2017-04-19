#!/bin/bash

# Constants
#
LOCK_PATH="locks/vault/bootstrap"
VAULT_URL="https://localhost:8200"

consulConfigPath=${1:-/etc/consul/acl.json}

function do_exit {
	rval=$1

	consul-cli kv unlock --session=${sessionid} ${LOCK_PATH}

	exit ${rval}
}
# Extract the master token from $consulConfigPath
token=$(jq -r .acl_master_token ${consulConfigPath})
if [ -n "${token}" ]; then
	consul_token="--token=${token}"
fi

# Wait for vault to become available
max_wait=60
while :; do
	curl -s ${VAULT_URL}/v1/sys/health >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		break
	fi

	if [ $SECONDS -gt $max_wait ]; then
		echo "Timeout waiting for vault to start"
		exit 1
	fi

	sleep 5 
done

sessionid=$(consul-cli kv lock --lock-delay=5s ${LOCK_PATH})

output=$(curl -s ${VAULT_URL}/v1/sys/health)

# Initialize vault iff it's not already initialized.
is_init=$(echo $output | jq -r .initialized)
if [ "${is_init}" == "true" ]; then
	echo "Vault already initialized"
	do_exit 0
fi

output=$(curl -X PUT -s -1 $VAULT_URL/v1/sys/init \
	-d '{ "secret_shares": 5, "secret_threshold": 3}')

keys=$(echo ${output} | jq -r .keys[])
root_token=$(echo ${output} | jq -r .root_token)

if [ -z "${keys}" -o -z "${root_token}" ]; then
	echo "No unseal keys or root_token"
	do_exit 1
fi

consul-cli kv write ${consul_token} secure/vault/keys ${keys}
if [ $? -ne 0 ]; then
	echo "Error initializing vault!"
	echo "Keys written to:       /etc/vault/keys"
	echo "Root token written to: /etc/vault/root_token"
	echo ${output} > /etc/vault/output
	echo ${keys} > /etc/vault/keys
	echo ${root_token} > /etc/vault/root_token
	do_exit 1
fi

consul-cli kv write ${consul_token} secure/vault/root_token ${root_token}
if [ $? -ne 0 ]; then
	echo "Error initializing vault!"
	echo "Keys written to:       /etc/vault/keys"
	echo "Root token written to: /etc/vault/root_token"
	echo ${output} > /etc/vault/output
	echo ${keys} > /etc/vault/keys
	echo ${root_token} > /etc/vault/root_token
	do_exit 1
fi

do_exit 0
