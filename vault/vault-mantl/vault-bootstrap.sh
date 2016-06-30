#!/bin/bash

# Constants
#
LOCK_PATH="locks/vault/bootstrap"
SECURE_TOKEN_PATH="/etc/default/consul_secure.env"
VAULT_URL="https://localhost:8200"

# Variables
#
token="$1"

function do_exit {
	rval=$1

	consul-cli kv-unlock --session=${sessionid} ${LOCK_PATH}

	exit ${rval}
}

if [ -z "${token}" -a -f ${SECURE_TOKEN_PATH} ]; then
	source ${SECURE_TOKEN_PATH}
	token=${SECURE_TOKEN}
fi

if [ -n "${token}" ]; then
	consul_token="--token=${token}"
fi

sessionid=$(consul-cli kv-lock --lock-delay=5s ${LOCK_PATH})

# Initialize vault iff it's not already initialized.
is_init=$(curl -s -1 $VAULT_URL/v1/sys/init | jq .initialized)
if [ "${is_init}" == "true" ]; then
	do_exit 0
fi

# Check the vault of ${LOCK_PATH}. If it is "init_done" then
# the initialization of vault is complete and the process needs
# to be restarted
#
is_init=$(consul-cli kv-read ${LOCK_PATH})
if [ "${is_init}" == "init_done" ]; then
	systemctl restart vault
	do_exit 0
fi

output=$(curl -X PUT -s -1 $VAULT_URL/v1/sys/init \
	-d '{ "secret_shares": 5, "secret_threshold": 3}')

keys=$(echo ${output} | jq -r .keys[])
root_token=$(echo ${output} | jq -r .root_token)

consul-cli kv-write ${consul_token} secure/vault/keys ${keys}
if [ $? -ne 0 ]; then
	echo "Error initializing vault!"
	echo "Keys written to:       /etc/vault/keys"
	echo "Root token written to: /etc/vault/root_token"
	echo ${output} > /etc/vault/output
	echo ${keys} > /etc/vault/keys
	echo ${root_token} > /etc/vault/root_token
	do_exit 1
fi

consul-cli kv-write ${consul_token} secure/vault/root_token ${root_token}
if [ $? -ne 0 ]; then
	echo "Error initializing vault!"
	echo "Keys written to:       /etc/vault/keys"
	echo "Root token written to: /etc/vault/root_token"
	echo ${output} > /etc/vault/output
	echo ${keys} > /etc/vault/keys
	echo ${root_token} > /etc/vault/root_token
	do_exit 1
fi

# Write "init_done" to LOCK_PATH so future runs don't try to re-init
consul-cli kv-write ${LOCK_PATH} init_done

do_exit 0
