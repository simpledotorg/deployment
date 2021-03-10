# Simple Sever Operations

We use [Ansible](http://docs.ansible.com/) to manage our deployment.

* [Setup](#setup)
* [Hosts](#hosts)
* [New Deployment](#new-deployment)
* [Changing Secrets](#changing-secrets)
* [Updating Configs](#updating-configs)
* [Deploying](#deploying)

## Setup

You just need a few things installed locally.

### Install Ansible with Homebrew

```
brew install ansible
```

### Install third-party roles

You then need to install any third party roles that we need via [ansible-galaxy](https://galaxy.ansible.com/docs/).
Run the below from the `ansible` directory:

```
ansible-galaxy install requirements.yml
```

### Obtain the Ansible vault password file

The Ansible vault password files are used to decrypt all Ansible vault files in this directory. Obtain the password file
from 1Password, and place it in a convenient location on your local machine, like `~/.vault_password`. You will need
this password file for most Ansible operations described below. See [Ansible Vault documentation](https://docs.ansible.com/ansible/2.8/user_guide/vault.html) 
for more details.

## Hosts

These are the environments

- bangladesh-demo
- bangladesh-production
- performance-primary
- sandbox
- qa
- staging
- production

Each environment has its own copies of the following files or folders inside the `ansible/` directory

* `hosts.<env_name>` - Host file containing IP addresses of servers
* `roles/simple-server/files/.env.<env_name>` - Encrypted file containing environment variables and application secrets
* `roles/common/ssh_keys/<env_name>/` - Directory containing SSH keys to be placed in the environment for developer access
* `roles/passenger/files/etc/nginx/sites-available/simple.org-<env_name>` - Nginx configuration file for the Nginx web
  servers placed on each EC2 instance

## New Deployment

To set up the required Ansible scripts for a new deployment of Simple, follow these steps

### 1. Create the following files for the new environment
  * `hosts.<env_name>` - Host file containing IP addresses of servers
  * `roles/simple-server/files/.env.<env_name>` - Encrypted file containing environment variables and application secrets
  * `roles/common/ssh_keys/<env_name>/` - Directory containing SSH keys to be placed in the environment for developer access
  * `roles/passenger/files/etc/nginx/sites-available/simple.org-<env_name>` - Nginx configuration file for the Nginx web
    servers placed on each EC2 instance

### 2. Configure the new environment

Populate the new files you've created with appropriate configurations. Use any of the existing files as a reference to
get started, and then customize for your new environment. Notably, be sure to update the following parameters:
* IP addresses in the `hosts` file
* Domain names in the `.env` and `simple.org-` Nginx files
* SSH keys in the `ssh_keys` directory
* Environment variables in the `.env` file

### 3. Deploy

Run a deployment with

```
ansible-playbook -v --vault-id /path/to/password_file deploy.yml -i hosts.<env_name>
```

## Changing secrets

Use the following command to change secrets.

```
ansible-vault edit --vault-id /path/to/password_file  roles/simple-server/files/.env.<env_name>
```

This will decrypt and open the appropriate config file in a temporary buffer for editing. Make any necessary edits, and
save and close the file. The ansible encrypted config file will now be updated. You can then commit these changes.


## Updating Configs

To update the appropriate environments with any new config changes merged to `master`, run the following command.

```
ansible-playbook -v --vault-id /path/to/password_file conf-update.yml -i hosts.<env_name>
```

Be sure to restart your web and worker processes to ensure the config changes are picked up by them.

```
bundle exec cap <country:environment> deploy:restart
bundle exec cap <country:environment> sidekiq:restart
```

## Deploying

It's super easy to deploy. You just tell Ansible which playbook to use (there's only one), and which hosts to deploy to.

In order to deploy, you will need SSH keys for the machine. If it's a new EC2 instance, you'll need to use the keys provided by Amazon when you set up the instance.

```
# For example:
ssh-add ~/.ssh/webservers.pem
```

```
ansible-playbook -v --vault-id /path/to/password_file deploy.yml -i hosts.<env_name>
```
