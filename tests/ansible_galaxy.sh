#!/bin/bash

ANSIBLE_ROLES_PATH=$1
ANSIBLE_GALAXY_FORCE=$2 # Note This variable has no effect. Even with force set the transitive dependencies are not being updated. Doing a delete of roles instead.

echo "ANSIBLE_GALAXY_FORCE=$ANSIBLE_GALAXY_FORCE"

# Run ansibile
# Note vagrant runs as root, but pwd is set to /home/vagrant

# Force removal of roles since --force does not work
rm -rf $ANSIBLE_ROLES_PATH
ansible-galaxy install -p $ANSIBLE_ROLES_PATH -c -v -r provision/requirements.yml $ANSIBLE_GALAXY_FORCE