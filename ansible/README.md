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

If you do not use Homebrew on MacOS, you can find installation instructions for your environment in
[Ansible's documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

### Install third-party roles

You then need to install any third party roles that we need via [ansible-galaxy](https://galaxy.ansible.com/docs/).
Run the below from the `ansible` directory:

```
ansible-galaxy install -r requirements.yml
```

### Obtain the Ansible vault password file

The Ansible vault password files are used to decrypt all Ansible vault files in this directory. Obtain the password file
from 1Password, and place it in a convenient location on your local machine, like `~/.vault_password`. You will need
this password file for most Ansible operations described below. See [Ansible Vault documentation](https://docs.ansible.com/ansible/2.8/user_guide/vault.html)
for more details.

#### Deploying your own instance of Simple?

If you are using not a part of the Simple engineering team, and you are deploying your own instance of
Simple, you should create your own Ansible password file. See [Ansible Vault documentation](https://docs.ansible.com/ansible/2.8/user_guide/vault.html)
for instructions on how to do so.

## Hosts

These are the environments managed by this Ansible repository. See the
[Simple Server Handbook](https://docs.google.com/document/d/1VTVBr8HcLWK6Nrg4gQkuQKb3H8EtiqQA-zGWTu3ddHc/edit)
for information on what each of these environments are for.

- bangladesh-demo
- bangladesh-production
- sandbox
- qa
- staging
- production

Each environment has its own copies of the following files or folders inside the `ansible/` directory

* `group_vars/<env_name>` - File containing some environment-specific Ansible variables
* `hosts.<env_name>` - Host file containing IP addresses of servers
* `roles/simple-server/files/.env.<env_name>` - Encrypted file containing environment variables and application secrets
* `roles/ssh/files/ssh_keys/<env_name>/` - Directory containing SSH keys to be placed in the environment for developer access
* `roles/passenger/files/etc/nginx/sites-available/simple.org-<env_name>` - Nginx configuration file for the Nginx web
  servers placed on each EC2 instance

## New Deployment

To set up the required Ansible scripts for a new deployment of Simple, follow these steps

### 1. Create the following files for the new environment

* `group_vars/<env_name>` - File containing some environment-specific Ansible variables
* `hosts.<env_name>` - Host file containing IP addresses of servers
* `roles/simple-server/files/.env.<env_name>` - Encrypted file containing environment variables and application secrets
* `roles/common/ssh_keys/<env_name>/` - Directory containing SSH keys to be placed in the environment for developer access
* `roles/passenger/files/etc/nginx/sites-available/simple.org-<env_name>` - Nginx configuration file for the Nginx web
  servers placed on each EC2 instance

### 2. Configure the new environment

Populate the new files you've created with appropriate configurations. Use any of the existing files as a reference to
get started, and then customize for your new environment. Notably, be sure to update the following parameters:

* Environment name in the `group_vars` file
* IP addresses in the `hosts` file. Sidekiq hosts should be added under the `[sidekiq]` group.
* Domain names in the `.env` and `simple.org-` Nginx files
* SSH keys in the `ssh_keys` directory
* Environment variables in the `.env` file

### 3. Deploy the configuration

Run a deployment with

```
ansible-playbook -v --vault-id /path/to/password_file deploy.yml -i hosts.<env_name>
```

This will configure your EC2 instances with all the necessary dependencies to run Simple.

### 4. Document

Add the new environment to the list of environments in the [Simple Server Handbook](https://docs.google.com/document/d/1VTVBr8HcLWK6Nrg4gQkuQKb3H8EtiqQA-zGWTu3ddHc/edit).

### 5. Deploy the application

Once you're done with these steps, use the [`Simple Server Deployment`](https://github.com/simpledotorg/simple-server#deployment)
documentation to install and run Simple Server.

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
