#!/usr/bin/env bash

set -xe

#./bin/terraform apply --auto-approve || true
#sleep 5
./bin/terraform apply --auto-approve
sleep 60

./fix-ssh-keys.pl
./fix-group-vars.pl

#ansible-playbook -i inventory playbook-00-*.yml ||  true
#sleep 5
ansible-playbook -i inventory playbook-00-*.yml; sleep 3

./fix-ssh-keys.pl

ansible-playbook -i inventory playbook-02-*.yml; sleep 3
ansible-playbook -i inventory playbook-04-*.yml; sleep 3
ansible-playbook -i inventory playbook-05-*.yml; sleep 3
ansible-playbook -i inventory playbook-06-*.yml; sleep 3
ansible-playbook -i inventory playbook-07-*.yml; sleep 3
ansible-playbook -i inventory playbook-08-*.yml; sleep 3
ansible-playbook -i inventory playbook-09-*.yml; sleep 3
ansible-playbook -i inventory playbook-10-*.yml; sleep 3
ansible-playbook -i inventory playbook-11-*.yml; sleep 3
ansible-playbook -i inventory playbook-12-*.yml; sleep 3
