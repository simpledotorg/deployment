# Simple Server deployment

This project contains deployment scripts for running [simple-server](https://github.com/simpledotorg/simple-server).

We use [terraform](https://www.terraform.io/) for provisioning servers and [ansible](http://docs.ansible.com/) for orchestration.

- [`terraform/`](/terraform)-  Scripts for provisioning infrastructure on AWS.
- [`ansible/`](/ansible) - Scripts for setting up simple-server on AWS.
- [`standalone/`](/standalone) - Scripts for self-hosting simple-server (bare-metal servers/vanilla VMs). It sets up simple-server with
- [`docs/`](/docs) - Miscellaneous docs
the required peripherals (load balancing, monitoring etc.) and aims to be independent of third party applications as far as possible.
