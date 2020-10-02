# Simple Sever Operations

We use [Ansible](http://docs.ansible.com/) to manage our deployment.

## Setup

You just need a few things installed locally.

#### Install Ansible with homebrew:

```
brew install ansible
```

You then need to install any third party roles that we need - from this `ansible` directory:

```
ansible-galaxy install requirements.yml
```

## Hosts

These are the environments

- sandbox
- qa
- staging
- production

Each environment has it's own `hosts.<env_name>` ([root](/) directory) file and `.env.<env_name>` ([roles/simple-server/files](roles/simple-server/files))

## Changing secrets

Use the following command to change secrets.

```
ansible-vault edit --vault-id /path/to/password_file  roles/simple-server/files/.env.<env_name>
```

This will decrypt and open the appropriate config file in a temporary buffer for editing. Make any necessary edits, and
save and close the file. The ansible encrypted config file will now be updated. You can then commit these changes.


## Updating configs

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
