#!/bin/bash

#token=$1

#if [ -z "${token}" ]; then
#	echo "No token provided for vault authentication!"
#	exit 1
#fi

consul_token=$(cat /etc/consul/acl.json | jq -r .acl_master_token)
if [ -z "${consul_token}" ]; then
	echo "Unable to extract consul root ACL token"
	exit 1
fi

vault_token=$(consul-cli kv read --token=${consul_token} secure/vault/root_token)
if [ -z "${vault_token}" ]; then
	echo "Unable to extract vault token"
	exit 1
fi

vault auth ${vault_token}
if [ $? -ne 0 ]; then
	echo "Failed to authenticate to vault"
	exit 1
fi

if [ -z "$(vault auth -methods | grep '^cert/')" ]; then
	vault auth-enable cert
	if [ $? -ne 0 ]; then
		echo "Failed to enable cert auth method"
		exit 1
	fi
fi

if [ -z "$(vault mounts | grep '^consul/')" ]; then
	vault mount consul
	if [ $? -ne 0 ]; then
		echo "Failed to mount consul backend"
		exit 1
	fi

	vault write consul/config/access address=127.0.0.1:8500 token=${consul_token}
	if [ $? -ne 0 ]; then
		echo "Unable to configure consul backend"
		exit 1
	fi
fi

if [ -z "$(vault read consul/roles/secure_token)" ]; then
	securePolicy=$(echo 'key "secure" { policy = "write" }' | base64)
	echo ${securePolicy} | vault write consul/roles/secure_token policy=-
	if [ $? -ne 0 ]; then
		echo "Failed creating secure_token policy"
		exit 1
	fi

	vault policy-write secure_token /etc/vault/policies/policy-secure-token.hcl
	if [ $? -ne 0 ]; then
		echo "Failed creating consul vault policy"
		exit 1
	fi

	vault write auth/cert/certs/secure_token \
		display_name=secure_consul_token \
		policies=secure_token \
		certificate=@/etc/pki/CA/ca.cert
	if [ $? -ne 0 ]; then
		echo "Failed creating cert auth method"
		exit 1
	fi
fi

exit 0
