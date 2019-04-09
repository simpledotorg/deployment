# Simple Sever Operations

We use [Ansible](http://docs.ansible.com/) to manage our deployment.

## Setup

You just need a few things installed locally.

#### Install Ansible with homebrew:

```
brew install ansible
```

## Hosts

These are the following environments:

- sandbox
- qa
- staging
- production

Each environment has it's own `hosts.<env_name>` (root directory) file and `.env.<env_name` (roles/simple-server/files)

## Changing secrets

```
ansible-vault edit --vault-id /path/to/password_file  roles/simple-server/files/.env.<env_name>
```


## Updating configs

```
ansible-playbook -v  --vault-id /path/to/password_file conf-update.yml -i hosts.<env_name>
```

## Deploying

It's super easy to deploy. You just tell Ansible which playbook to use (there's only one), and which hosts to deploy to.

In order to deploy, you will need SSH keys for the machine. If it's a new EC2 instance, you'll need to use the keys provided by Amazon when you set up the instance.

```
# For example:
ssh-add ~/.ssh/webservers.pem
```

```
ansible-playbook -v  --vault-id /path/to/password_file deploy.yml -i hosts.<env_name>
```
