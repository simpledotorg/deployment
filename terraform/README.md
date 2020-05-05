# Terraform Scripts for provisioning AWS

## Initial setup

This setup needs to be run only once per AWS account.

- Create an AWS account.
- The repo contains a separate directory for each AWS account. For setting this up with a new account,
  we recommend creating a directory similar to `development/` with the appropriate profile set in its `main.tf`.
  See [managing environments](#managing-environments) to customize your infra.
- Create a new group called `Provisioners` with the following policies (`My Security Credentials` > `Groups` > `Create new group`)
 ```
  AmazonRDSFullAccess
  AmazonEC2FullAccess
  AmazonElastiCacheFullAccess
  AmazonS3FullAccess
  AmazonDynamoDBFullAccess
  AmazonVPCFullAccess
 ```
- Create a user with API only access and add it to the `Provisioners` group.
- Add the user's access id and secret key to AWS credentials file under the appropriate profile.
 See [using AWS credential files.](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- Create an s3 bucket. Add the bucket's name to `main.tf` > `terraform` > `backend` > `bucket`
- Create a [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html) table
  called `terraform-lock` with `LockID` as primary key.

## Using the scripts

- We use [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for managing secrets. Decrypt the
  `terraform.tfvars.vault` file by running:
    ```bash
    cat terraform.tfvars.vault | ansible-vault decrypt --vault-id ../../password_file > terraform.tfvars
    ```
  This will create a `terraform.tfvars` file for local use. You can supply your own `terraform.tfvars` if you don't have vault access.
- You will also need to decrypt the SSL cert vault files. You can provide your own cert files otherwise.
- Run `terraform init` to initialise your setup.
- To propagate changes to the configuration run
    ```bash
    terraform plan
    terraform apply
    ```

## Managing environments

- `main.tf` contains several `modules`. Each `module` captures the resources for an env (sandbox, qa, staging etc).
- To setup a new env, you can start with duplicating one of the modules and tweak it to your needs.
- To delete an env, simply remove the module from `main.tf`.

## Helpful commands

### Viewing/Editing vault files

```bash
ansible-vault view --vault-id ../../password_file roles/load-balancing/vars/ssl-vault.yml
ansible-vault edit --vault-id ../../password_file roles/load-balancing/vars/ssl-vault.yml
```

### Commiting secrets

- Encrypt your secrets into a vault.
```bash
cat terraform.tfvars | ansible-vault encrypt --vault-id ../../password_file --output terraform.tfvars.vault
```
- Check in the vault file.
