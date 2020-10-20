# Simple Server deployment

This project contains deployment scripts for running [simple-server](https://github.com/simpledotorg/simple-server).

We use [terraform](https://www.terraform.io/) for provisioning servers and [ansible](http://docs.ansible.com/) for orchestration.

- [`terraform/`](/terraform)-  Scripts for provisioning infrastructure on AWS.
- [`ansible/`](/ansible) - Scripts for setting up simple-server on AWS.
- [`standalone/`](/standalone) - Scripts for self-hosting simple-server (bare-metal servers/vanilla VMs). It sets up simple-server with the required peripherals (load balancing, monitoring etc.) and aims to be independent of third party applications as far as possible.
- [`docs/`](/docs) - Miscellaneous docs.

# Terraform migration status

The `terraform/` setup is not fully utilized for all running environments yet. We track the current environment status in this [document](https://docs.google.com/spreadsheets/d/1JCfFYetk9Jrtc5iUHp-7Fx5V3QqpuCWojjcEibRJN7I/edit#gid=0) (refer to `Provisioned with terraform`) along with other notes and details.

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

# How to add an SSH key to view SBX data in your local
1. Create a new file in `ansible/roles/common/files/ssh_keys/sandbox` with your name as the file name in lowercase
2. In your terminal run `pbcopy < ~/.ssh/id_rsa.pub` to copy your SSH key
3. Paste the SSH key in the new file you created
4. Create a new branch and submit a PR
5. Wait for the PR to be reviewed, merged, and deployed to Sandbox