Scripts for setting up simple-server in a standalone environment.

# Setting up simple-server

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
- Run `ansible-playbook --vault-id <path/to/password_file> all.yml -i ../hosts/icmr/playground`
    - Simple server should now be installed, running and accessible on your domain.

# Provisioning Testing Servers
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

# Helpful commands:
### Editing vault files

There are other vault files that are checked into this repository that do not have a corresponding local decrypted version
for development. You can view or edit the contents of these vault files directly by running:

```bash
ansible-vault view --vault-id ../../password_file roles/passenger/vars/ssl-vault.yml
ansible-vault edit --vault-id ../../password_file roles/passenger/vars/ssl-vault.yml
```
