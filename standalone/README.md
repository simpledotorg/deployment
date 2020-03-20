Scripts for setting up simple-server in a standalone environment.

## Table of Contents

* [Simple Architecture](#simple-architecture)
* [Setting Up `simple-server`](#setting-up-simple-server)
* [Provisioning Testing Servers](#provisioning-testing-servers)
* [Helpful Commands](#helpful-commands)

## Simple Architecture

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

Below are instructions to setting up simple-server on a set of servers. These instructions assume that you have already
provisioned servers and have their static IP addresses available. If you don't have servers provisioned yet, you will
need to do so first.

These instructions are to be followed in the `standalone` directory of this repository.

- `cd ansible/`
- Add the IP addresses of your servers to the `hosts/icmr/playground` Ansible inventory file.
- Set up your domain and SSL certificate.
    - Add SSL certificates for your domain to `roles/load_balancing/vars/ssl-vault.yml`. This is an encrypted Ansible
      vault file. See [Editing vault files](#editing-vault-files) for instructions on how to edit it.
    - Add the SSL certificate domain names to `haproxy_cert_names` in `group_vars/load_balancing.yml`
    - Configure your DNS records to point your domain/subdomain to the load balancer's IP address. You may do this by
      creating/editing an ALIAS or CNAME record.
- Set the following in the `hosts/icmr/playground` Ansible inventory file
    - Set `domain_name` to your domain name (eg. `playground.simple.org`)
    - Set `deploy_env` to your desired environment name (eg. `staging`, `production`, `sandbox`)
- Run `make init`
- Run `make all` to setup simple-server on your servers.
    - Simple server should now be installed, running and accessible on your domain.

## Provisioning Testing Servers

For testing purposes, `provision-playground/terraform` contains a terraform script to spin up servers on digitalocean.

### Decrypt the terraform vault

- Decrypt the `terraform.tfvars.vault` file by running:
    ```bash
    cat terraform.tfvars.vault | ansible-vault decrypt --vault-id ../../password_file > terraform.tfvars
    ```
  This will create a `terraform.tfvars` file for local use.

### Add SSH credentials

- Add your SSH key to the list of SSH keys in the digitalocean console ([ref](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/)).
- Add your SSH fingerprint to the `terraform.tfvars` file.

### Provision the test servers

- Add aws credentials to `~/.aws/credentials` (for storing tfstate to s3):
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
ansible-vault view --vault-id ../../password_file roles/passenger/vars/ssl-vault.yml
ansible-vault edit --vault-id ../../password_file roles/passenger/vars/ssl-vault.yml
```

### Updating ssh keys
Add keys to `ansible/roles/ssh/` under the appropriate environment.
```bash
make update-ssh-keys hosts=icmr/playground
```
Note that this clears any old keys present on the servers.
