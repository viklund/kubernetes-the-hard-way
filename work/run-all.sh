#!/usr/bin/env bash

# Openstack connection iformation
source SNIC\ 2018_10-38-HPC2N-openrc.sh
# Openstack password
source password

set -xe

# Bring environment up
./bin/terraform apply --auto-approve
sleep 60

# Make sure that the local keys are updated and correct
./fix-ssh-keys.pl
./fix-group-vars.pl

# Set up some ip tables routes
ansible-playbook -i inventory playbook-00-*.yml; sleep 3

## Run all the playbooks. One playbook per step in the guide
ansible-playbook -i inventory playbook-02-*.yml; sleep 3
ansible-playbook -i inventory playbook-04-*.yml; sleep 3
ansible-playbook -i inventory playbook-05-*.yml; sleep 3
ansible-playbook -i inventory playbook-06-*.yml; sleep 3
ansible-playbook -i inventory playbook-07-*.yml; sleep 3
ansible-playbook -i inventory playbook-08-*.yml; sleep 3
ansible-playbook -i inventory playbook-09-*.yml; sleep 3
ansible-playbook -i inventory playbook-10-*.yml; sleep 3
ansible-playbook -i inventory playbook-11-*.yml; sleep 3
ansible-playbook -i inventory playbook-12-*.yml
