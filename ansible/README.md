# RedApp Sever Operations

We use [Ansible](http://docs.ansible.com/) to manage our deployment.

## Setup

You just need a few things installed locally.

#### Install Ansible with homebrew:

```
brew install ansible
```

## Deploying

It's super easy to deploy. You just tell Ansible which playbook to use (there's only one), and which hosts to deploy to.

Hosts are split into `hosts.staging` and `hosts.production` files.

In order to deploy, you will need SSH keys for the machine. If it's a new EC2 instance, you'll need to use the keys provided by Amazon when you set up the instance.

```
# For example:
ssh-add ~/.ssh/webservers.pem
```

### Staging

```
ansible-playbook -v --vault-id @prompt deploy.yml -i hosts.staging
```

### Production

```
ansible-playbook deploy.yml -i hosts.production
```

### Changing secrets
```
ansible-vault edit --vault-id /path/to/password_file  roles/redapp-server/files/.env.staging
```
