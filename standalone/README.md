Scripts for setting up simple-server in a standalone environment.

# Terraform:
For testing purposes, `provision-playground/terraform` contains a terraform script to spin up boxes on digitalocean.
- Add digitalocean creds and ssh fingerprints to `terraform.tfvars` (use `terraform.tfvars.sample`)
- Add aws credentials to `~/.aws/credentials` (for storing tfstate to s3):
    ```
    [development]
    aws_access_key_id=
    aws_secret_access_key=
    ```
- `terraform init`
- `terraform plan`
- `terraform apply`
- Add IPs of created boxes to `ansible/hosts/icmr/playground`.

# Setting up simple-server
- `cd ansible/`
- Add hosts to `hosts/icmr/playground`.
- To setup the domain:
    - Add certificates to roles/load_balancing/vars/ssl-vault.yml
    - Add cert host names to `haproxy_cert_names` in `group_vars/load_balancing.yml`
    - Add load balancer IP to DNS.
- Set `domain_name` and `deploy_env` in the inventory file.
- `ansible-playbook --vault-id ../../password_file all.yml -i ../hosts/icmr/playground`

# Helpful commands:
### Using terraform with terraform.tfvars.vault
- `terraform.tfvars.vault` contains secrets for our test digitalocean account. To decrypt:
    ```bash
    cat terraform.tfvars.vault | ansible-vault decrypt --vault-id ../../password_file > terraform.tfvars
    ```
- To encrypt it back (when checking in to git):
    ```bash
    cat terraform.tfvars | ansible-vault encrypt --vault-id ../../password_file --output terraform.tfvars.vault
    ```
### Recreating terraform boxes:
- `terraform destroy`
- `terraform plan`
- `terraform apply`
### Editing vault files
```bash
ansible-vault edit --vault-id ../../password_file roles/passenger/vars/ssl-vault.yml
```
