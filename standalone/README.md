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
```
### Configure the ansible setup:

- `cd ansible/`
- Create an hosts inventory file. The setup uses `hosts/icmr/playground` as an example. You can use it as a template to setup your own.
- Add the IP addresses of your servers to the inventory file.
- Set up your domain and SSL certificate.
    - Add SSL certificates for your domain to `roles/load_balancing/vars/ssl-vault.yml`. This is an encrypted Ansible
      vault file. See [Editing vault files](#editing-vault-files) for instructions on how to edit it.
    - Add the SSL certificate domain names to `haproxy_cert_names` in `group_vars/load_balancing.yml`
    - Configure your DNS records to point your domain/subdomain to the load balancer's IP address. You may do this by
      creating/editing an ALIAS or CNAME record.
- Set the following in the inventory file
    - Set `domain_name` to your domain name `example.com`
    - Set `deploy_env` to your desired environment name (eg. `demo`, `production`, `sandbox`)

### Run the ansible scripts

- Run `make init`
- Run `make all` to setup simple-server on your servers.
    - Simple server should now be installed, running and accessible on your domain.
    - Note: Some versions of MacOS fail on running the node exporter setup scripts due to
      [this issue](https://github.com/cloudalchemy/ansible-node-exporter/issues/54). You will have to
     `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to fix this.

## Provisioning Testing Servers

For testing purposes, `provision-playground/terraform` contains a terraform script to spin up servers on digitalocean.
You will need a digitalocean account and an AWS account (for storing tfstate to s3).

### Decrypt the terraform vault

- Decrypt the `terraform.tfvars.vault` file by running:
    ```bash
    cat terraform.tfvars.vault | ansible-vault decrypt --vault-id ../../password_file > terraform.tfvars
    ```
  This will create a `terraform.tfvars` file for local use. You may use the `terraform.tfvars.sample` to set up credentials
  if you don't have vault access. See [creating a personal access token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
  to generate your `do_token`.

### Add SSH credentials

- Add your SSH key to the list of SSH keys in the digitalocean console ([ref](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/)).
- Add your SSH fingerprint to the `terraform.tfvars` file.

### Provision the test servers

- Install ansible with homebrew
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
- Copy over IPs of the created servers to `ansible/hosts/icmr/playground`. You can use any of the servers for any purpose, they are generic.

### Check in your vault

- Update the vault by running:
    ```bash
    cat terraform.tfvars | ansible-vault encrypt --vault-id ../../password_file --output terraform.tfvars.vault
    ```
  Check in the updated vault.

## Helpful Commands

### Editing vault files

There are other vault files that are checked into this repository that do not have a corresponding local decrypted version
for development. You can view or edit the contents of these vault files directly by running:

```bash
ansible-vault view --vault-id ../../password_file roles/load-balancing/vars/ssl-vault.yml
ansible-vault edit --vault-id ../../password_file roles/load-balancing/vars/ssl-vault.yml
```

### Making a deploy
```bash
make deploy hosts=icmr/playground
```
This deploys simple-server/master on hosts.

### Updating ssh keys
Add keys to `ansible/roles/ssh/` under the appropriate environment.
```bash
make update-ssh-keys hosts=icmr/playground
```
Note that this clears any old keys present on the servers.

### Updating app config
The app's .env file sits in `ansible/roles/deploy/templates/.env.j2`.
Variables are sourced from `ansible/roles/deploy/templates/vars`
```bash
make update-app-config hosts=icmr/playground
```

### Restarting passenger
```bash
make restart-passenger hosts=icmr/playground
```
Note that this restarts passenger on all servers.

### Restarting sidekiq
```bash
make restart-sidekiq hosts=icmr/playground
```

