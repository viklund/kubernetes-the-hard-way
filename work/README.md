# Kubernetes the hard way on openstack

This is my deployment of kubernetes the hard way on top of openstack instead of
GCE.

It's also done with terraform and ansible instead of running the shell commands
directly.

## Prerequisites

Terraform and ansible is required. I've installed ansible in a python virtual
environment in the `venv/` subdirectory and the terraform binary I have in the
`bin/` subdirectory.

## Guide

### Terraform

The terraform setup is in `main.tf` and the `tf/` subdirectory for modules.
It's fairly straightforward.

### Ansible

Every step of the guide is done with one (or more) ansible playbooks with a
name on the form `playbook-<STEP>-<SOME DESCRIPTION>.yml`.

The smoke tests in step 13 has to be done manually.
