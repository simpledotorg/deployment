# Terraform Scripts for provisioning AWS

## Overview

This repository contains one folder for each AWS account whose infrastructure is managed through terraform. Currently,
it supports:
* [`development`](/development) - The Simple AWS Dev account, managing Sandbox, QA, and Security environments
* [`bangladesh`](/bangladesh) - The Simple Bangladesh account, managing Bangladesh Demo and Bangaldesh Production
  environments

If you want to set up a new AWS account, go to [Setting Up A New AWS Account](#setting-up-a-new-aws-account). Otherwise
go to [Getting Started](#getting-started).

## Getting Started

### 1. Add the master AWS SSH key to your machine

* Create a blank SSH keypair in your SSH directory

```bash
$ touch ~/.ssh/simple_aws_key ~/.ssh/simple_aws_key.pub
```

* Find the "AWS Master SSH Key" in 1Password

* Add the contents of the "Private key" to `simple_aws_key`

* Add the contents of the "Public key" to `simple_aws_key.pub`

### 2. Decrypt all encrypted terraform files

Sensitive terraform configuration is stored and checked into Github as encrypted files using
[ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). These files are decrypted locally and
git-ignored for local development. Before doing any development, run `./decrypt path-to-your-vault-file` to make sure to
decrypt the latest versions of the encrypted ansible vault files in this directory. For example:

```bash
$ cd terraform
$ ./decrypt ~/code/simple/ansible_password_file

Decrypting bangladesh/bd.simple.org.chain.pem.vault to bangladesh/bd.simple.org.chain.pem
Decrypting bangladesh/bd.simple.org.pem.vault to bangladesh/bd.simple.org.pem
Decrypting bangladesh/bd.simple.org.private_key.pem.vault to bangladesh/bd.simple.org.private_key.pem
Decrypting bangladesh/terraform.tfvars.vault to bangladesh/terraform.tfvars
Decrypting development/simple.org.chain.pem.vault to development/simple.org.chain.pem
Decrypting development/simple.org.pem.vault to development/simple.org.pem
Decrypting development/simple.org.private_key.pem.vault to development/simple.org.private_key.pem
Decrypting development/terraform.tfvars.vault to development/terraform.tfvars
Decryption complete!
```

Even if you've already decrypted these files, it's a good idea to do this again, as the contents of the encrypted files
may have changed since you last decrypted them.

### 3. Navigate to the AWS environment that you wish to work on.

```bash
$ cd bangladesh
```

### 4. If you haven't already, initialize Terraform. This command is safe to re-run several times.

```bash
$ terraform init
```

### 5. Encrypt any changed secrets

If you modify a decrypted file during development, update the encrypted file and check it into the repository. For
example, if you've modified `terraform.tfvars`,

```bash
$ cat terraform.tfvars | ansible-vault encrypt --vault-id ~/code/simple/ansible_password --output terraform.tfvars.vault
$ git add terraform.tfvars.vault
$ git commit -m 'Update Bangladesh terraform secrets'
```

### 6. Verify your changes

After development, run `terraform plan` to check whether the execution plan for your set of changes matches your
expectations without making any changes to real resources.

```bash
$ terraform plan
```

### 7. Apply

Once you are confident with the execution plan, run `terraform apply` to apply your changes to the AWS environment.

```bash
$ terraform apply
```

## Setting Up A New AWS Account

If you are setting up a new AWS account to be managed by terraform (eg. a Simple Server instance in a new country),
follow these instructions. This setup needs to be run only once per AWS account.

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
