#!/usr/bin/env bash

set -xe

#./bin/terraform apply --auto-approve || true
#sleep 5
#./bin/terraform apply --auto-approve
#sleep 20

./fix-ssh-keys.pl
./fix-group-vars.pl

ansible-playbook -i inventory playbook-00-*.yml

./fix-ssh-keys.pl

ansible-playbook -i inventory playbook-02-*.yml
ansible-playbook -i inventory playbook-04-*.yml
ansible-playbook -i inventory playbook-05-*.yml
ansible-playbook -i inventory playbook-06-*.yml
ansible-playbook -i inventory playbook-07-*.yml
ansible-playbook -i inventory playbook-08-*.yml
ansible-playbook -i inventory playbook-09-*.yml
