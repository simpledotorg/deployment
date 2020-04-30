# Simple Server deployment

This project contains deployment scripts for running [simple-server](https://github.com/simpledotorg/simple-server).

We use [terraform](https://www.terraform.io/) for provisioning servers and [ansible](http://docs.ansible.com/) for orchestration.

- `terraform/`-  Scripts for provisioning infrastructure on AWS.
- `ansible/` - Scripts for setting up simple-server on AWS.
- `standalone/` - Scripts for self-hosting simple-server (bare-metal servers/vanilla VMs). It sets up simple-server with 
the required peripheral applications (load balancing, monitoring et al) and aims to be detached from 
third party applications as far as possible. 
