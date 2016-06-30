#!/bin/bash

# Constants
#
SECURE_TOKEN_PATH="/etc/default/consul_secure.env"
VAULT_URL="https://localhost:8200"

# Variables
#
token="$1"

if [ -z "${token}" -a -f ${SECURE_TOKEN_PATH} ]; then
  source ${SECURE_TOKEN_PATH}
  token=${SECURE_TOKEN_PATH}
fi

vaultfs mount --address=$VAULT_URL -t ${token} ${VAULT_MOUNT_DIR}
