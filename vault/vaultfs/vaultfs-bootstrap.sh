#!/bin/bash

# Constants
# Found in /etc/sysconfig/vaultfs.sysconfig

if [ -z "${VAULT_TOKEN}" -a -f ${SECURE_TOKEN_PATH} ]; then
  source ${SECURE_TOKEN_PATH}
  VAULT_TOKEN=${SECURE_TOKEN}
fi

function start {
  mkdir "$VAULTFS_MOUNTPOINT"
  mkdir "$VAULTFS_DOCKER_MOUNTPOINT"
  vaultfs mount --address="${VAULT_ADDRESS}" -t "${VAULT_TOKEN}" "${VAULTFS_MOUNTPOINT}" &
  vaultfs docker --address="$VAULT_ADDRESS" -t "${VAULT_TOKEN}" "${VAULTFS_DOCKER_MOUNTPOINT}" &
  wait
}

start &
