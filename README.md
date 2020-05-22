# Simple Server deployment

This project contains deployment scripts for running [simple-server](https://github.com/simpledotorg/simple-server).

We use [terraform](https://www.terraform.io/) for provisioning servers and [ansible](http://docs.ansible.com/) for orchestration.

- [`terraform/`](/terraform)-  Scripts for provisioning infrastructure on AWS.
- [`ansible/`](/ansible) - Scripts for setting up simple-server on AWS.
- [`standalone/`](/standalone) - Scripts for self-hosting simple-server (bare-metal servers/vanilla VMs). It sets up simple-server with the required peripherals (load balancing, monitoring etc.) and aims to be independent of third party applications as far as possible.
- [`docs/`](/docs) - Miscellaneous docs.

# Setting up Ansible Vault

We use [ansible vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to manage encrypted secrets. The recommended way to set things up is below, which will allow you to use `ansible-vault` to view / edit encryptes files without having to
contsantly type in the password. This setup will also allow you to use `git diff` locally on encrypted files and make sense of them. Otherwise you are just diff'ing binary blobs.

1. Place the vault password in the repository root in a file named `.vault_password`. This file is gitignored and should never be checked in.
2. Run the following to configure the diff driver
```
git config --global diff.ansible-vault.textconv "ansible-vault view"
```
3. Configure the vault password location in an env var - you'll probably want to add this to your shell profile:
```
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_password
```

Now you can use git diff to view any changes locally on `.env` files.