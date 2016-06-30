#!/bin/bash

# Constants
#
SECURE_TOKEN_PATH="/etc/default/consul_secure.env"

if [ -z "${VAULT_TOKEN}" -a -f ${SECURE_TOKEN_PATH} ]; then
  source ${SECURE_TOKEN_PATH}
  VAULT_TOKEN=${SECURE_TOKEN_PATH}
fi

vaultfs mount --address=$VAULT_ADDRESS -t ${VAULT_TOKEN} ${VAULT_MOUNTPOINT}
