Scripts for setting up simple-server in a standalone environment.

## Table of Contents

* [Simple Standalone Architecture](#simple-standalone-architecture)
* [Setting Up `simple-server`](#setting-up-simple-server)
* [Provisioning Testing Servers](#provisioning-testing-servers)
* [Helpful Commands](#helpful-commands)

## Simple Standalone Architecture

### Components

The Simple Server setup managed by this tooling has the following components.

| Component                          | Purpose | Technologies |
| ---------                          | ------- | ------------ |
| Primary relational database        | Primary application database | [PostgreSQL](https://www.postgresql.org/) |
| Secondary relational database      | Follower application database | [PostgreSQL](https://www.postgresql.org/) |
| Primary non-relational datastore   | Datastore for application caching and background jobs | [Redis](https://redis.io/) |
| Secondary non-relational datastore | Follower for primary non-relational datastore | [Redis](https://redis.io/) |
| Web servers                        | Dashboard web application and APIs | [Ruby on Rails](https://rubyonrails.org/)<br>[Passenger](https://www.phusionpassenger.com/) |
| Background processing servers      | Perform enqueued tasks asynchronously | [Sidekiq](https://github.com/mperham/sidekiq) |
| Load balancer                      | Route incoming web requests across web servers | [HAProxy](http://www.haproxy.org/) |
| System health monitoring           | Monitor the system health of all Simple servers | [Prometheus](https://prometheus.io/)<br>[Grafana](https://grafana.com/) |
| Storage                            | Large storage location for logs and database backups | [`rsync`](https://linux.die.net/man/1/rsync) |

### Topography

These components are arranged in the following topography.

![topography](https://docs.google.com/drawings/d/e/2PACX-1vTr2ryR_vqxAtdNCzKxn1pIdz3b57be8j3iHAVBEDBGstA6jGqOX6deyoXeWBXEk_yzeybFsmrzm5Ww/pub?w=960&amp;h=720)

If this image is out-of-date, you can edit it [here](https://docs.google.com/drawings/d/1jHZeW141ivRUAWhHEduwlyasFxNzZ1Nk2V_AQ12w4p8/edit).

## Setting Up `simple-server`

These instructions assume that you have already provisioned servers and have their static IP addresses available.
If you don't have servers provisioned yet, you will need to do so first. See [provisioning testing servers](#provisioning-testing-servers).

These instructions are to be followed in the [standalone](/standalone) directory.

### Install local requirements
```bash
brew install ansible@2.8.3 gnu-tar
make init
```

### Setup remote user

- You will need to setup a sudo remote user with `NOPASSWD` access on the servers.
The scripts assume an `ubuntu` user by default, this can be configured in [`ansible.cfg`](/standalone/ansible/ansible.cfg).
```
sudo visudo

# At the end of the file add
ubuntu     ALL=(ALL) NOPASSWD:ALL
```
Note: AWS ec2 instances already come with an `ubuntu` sudoer.

- Setup your keys on the server. Make sure you can establish an SSH connection to your server as the remote user (default `ubuntu`).

### Configure the ansible setup:

- `cd ansible/`
- Create an hosts inventory file. The setup uses `hosts/sample/playground` as an example. You can use it as a template to setup your own.
- Add the IP addresses of your servers to the inventory file.
- Set up your domain and SSL certificate.
    - Add SSL certificates for your domain to `roles/load_balancing/vars/ssl-vault.yml`. This is an encrypted Ansible
      vault file. See [Editing vault files](#editing-vault-files) for instructions on how to edit it.
    - Add the SSL certificate domain names to `haproxy_cert_names` in `group_vars/load_balancing.yml`
    - Configure your DNS records to point your domain/subdomain to the load balancer's IP address. You may do this by
      creating/editing an ALIAS or CNAME record.
- Configure app environment variables in `roles/simple-server/vars/<deploy_env>/`. `deploy_env` is the shortname you wish to give to
  a specific deployment (e.g. `ethiopia-demo`, `bangladesh-production`).
    - `secrets.yml` contains secret env vars. Make sure this file is encrypted.
    - See `roles/simple-server/vars/sample/` for a sample. These vars are interpolated into `roles/simple-server/vars/templates/.env.j2` and shipped.
- Add your ssh keys to `ssh/files/ssh_keys/<deploy_env>`. These keys are added to all the servers to access the remote user(`ubuntu`) and the `deploy` user.
- Set the following in the inventory file
    - Set `domain_name` to your domain name `example.com`
    - Set `deploy_env` to the correct shortname (e.g. `ethiopia-demo`, `bangladesh-production`)
    - Set `app_env` to your desired environment name (eg. `demo`, `production`, `sandbox`)
- To setup slack alerts (optional), you will need to add the webhook URL in `roles/monitoring/vars/<deploy_env>/secrets.yml`.
  To setup the slack channel edit the config in `roles/monitoring/vars/alertmanager.yml`.

### Run the ansible scripts

- Run `make init`
- Run `make all hosts=sample/playground` to setup simple-server on your servers.
- Simple server should now be installed, running and accessible on your domain.

### Vault password

This document makes liberal use of a generic `~/.vault_password` file. But keep in mind, that different environments might be signed with different private keys.

As of now, there are 2 vault passwords:

- `vault_password`
- `vault_password_et`

|                | India          | Bangladesh     | Ethiopia          | Dev            |
|----------------|----------------|----------------|-------------------|----------------|
| Production     | vault_password | vault_password | vault_password_et | -              |
| Demo / Staging | vault_password | vault_password | vault_password_et | -              |
| QA             | -              | -              | -                 | vault_password |
| Security       |                |                | -                 | vault_password |
| Sandbox        | -              | -              | -                 | vault_password |

## Helpful Commands

### Editing vault files

There are other vault files that are checked into this repository that do not have a corresponding local decrypted version
for development. You can view or edit the contents of these vault files directly by running:

```bash
ansible-vault view --vault-id ~/.vault_password roles/load-balancing/vars/ssl-vault.yml
ansible-vault edit --vault-id ~/.vault_password roles/load-balancing/vars/ssl-vault.yml
```

### Making a deploy
```bash
make deploy hosts=sample/playground
```
This deploys simple-server/master on hosts.

### Running capistrano commands

You can run cap commands on the servers from the `simple-server` repository.
- Add a new stage (`config/deploy/<country_name>/<environment>`) with the `webserver` and `sidekiq` addresses as in the inventory file.
- Add the appropriate roles to the servers. Make sure these host addresses are always in sync with the `deployment` repository.

Note: We run deployments through ansistrano. Running a `cap deploy` is not recommended and breaks currently.

### Updating ssh keys
Add keys to `ansible/roles/ssh/` under the appropriate environment.
```bash
make update-ssh-keys hosts=sample/playground
```
Note that this clears any old keys present on the servers.

### Updating app config
The app's .env file sits in `ansible/roles/simple-server/templates/.env.j2`.
Variables are sourced from `ansible/roles/simple-server/templates/vars`
```bash
make update-app-config hosts=sample/playground
```

### Restarting passenger
```bash
make restart-passenger hosts=sample/playground
```
Note that this restarts passenger on all servers.

### Restarting sidekiq
```bash
make restart-sidekiq hosts=sample/playground
```
## Provisioning Testing Servers

For testing purposes, `terraform/playground` contains a terraform script to spin up servers on digitalocean.
You will need a digitalocean account and an AWS account (for storing tfstate to s3).

### Decrypt the terraform vault

- Decrypt the `terraform.tfvars.vault` file by running:
    ```bash
    cat terraform.tfvars.vault | ansible-vault decrypt --vault-id ~/.vault_password > terraform.tfvars
    ```
  This will create a `terraform.tfvars` file for local use. You may use the `terraform.tfvars.sample` to set up credentials
  if you don't have vault access. See [creating a personal access token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
  to generate your `do_token`.

### Add SSH credentials

- Add your SSH key to the list of SSH keys in the digitalocean console ([ref](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/)).
- Add your SSH fingerprint to the `terraform.tfvars` file.

### Provision the test servers

- Install terraform with homebrew
```bash
brew install terraform0.12.21
```
- Add aws credentials to `~/.aws/credentials`:
    ```
    [development]
    aws_access_key_id=
    aws_secret_access_key=
    ```
- Run the following commands:
    ```
    terraform init
    terraform plan
    terraform apply
    ```
This will provision the necessary servers for an instance of simple-server on digitalocean. The IPs of the servers will be printed at the end.
- Copy over IPs of the created servers to `ansible/hosts/sample/playground`. You can use any of the servers for any purpose, they are generic.

### Check in your vault

- Update the vault by running:
    ```bash
    cat terraform.tfvars | ansible-vault encrypt --vault-id ~/.vault_password --output terraform.tfvars.vault
    ```
  Check in the updated vault.

## Troubleshooting

Depending on your system, you may run into the following known issues:

### Errors with cloudalchemy.node_exporter

If you see output like this, it's likely due to [this issue](https://github.com/cloudalchemy/ansible-node-exporter/issues/54).

```
TASK [cloudalchemy.node_exporter : Get checksum list from github] *******************************************************************************************************************************************************
objc[5848]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called.
objc[5848]: +[__NSCFConstantString initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
ERROR! A worker was found in a dead state
```


#### Run this to fix:
```
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```
