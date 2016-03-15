#!/usr/bin/env bash
# make sure the VM is running
if [ "$(vagrant status | grep 'running')" == "" ]; then
    vagrant up
fi

# setup
SSH_CONFIG=$(mktemp /tmp/ssh-config.XXXXX)
vagrant ssh-config > $SSH_CONFIG

# execute
ssh -F $SSH_CONFIG default "/home/vagrant/go/bin/hammer build --search=/vagrant --output=/vagrant/out $*"
STATUS=$?

# cleanup
rm $SSH_CONFIG

exit $STATUS
