# Terraform Scripts for provisioning AWS

## Overview

This repository contains one folder for each AWS account whose infrastructure is managed through terraform. Currently,
it supports:
* [`development`](/development) - The Simple AWS Dev account, managing Sandbox, QA, and Security environments
* [`bangladesh`](/bangladesh) - The Simple Bangladesh account, managing Bangladesh Demo and Bangaldesh Production
  environments
* [`example`](/example) - A sample directory used as a template for creating new AWS accounts

If you want to set up a new AWS account, go to [Setting Up A New AWS Account](#setting-up-a-new-aws-account). Otherwise
go to [Getting Started](#getting-started).

## Getting Started

### 1. Add the master AWS SSH key to your machine

This is the SSH key that will be placed on all provisioned instances for initial access. The key is read off of your
local machine and copied to AWS by terraform.

* Create a blank SSH keypair in your SSH directory

```bash
$ touch ~/.ssh/simple_aws_key ~/.ssh/simple_aws_key.pub
```

* Find the "AWS Master SSH Key" in 1Password

* Add the contents of the "Private key" to `simple_aws_key`

* Add the contents of the "Public key" to `simple_aws_key.pub`

#### Deploying your own instance of Simple?

If you are using not a part of the Simple engineering team, and you are deploying your own instance of
Simple, you should create your own SSH keypair.

* Create a keypair. You can use [any resource](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for more information on how to generate an SSH keypair.

```bash
$ ssh-keygen -t ed25519-sk -C "your_email@example.com"
```

* When prompted, enter `simple_aws_key` as the name of the new keypair.

* Add the new key to your SSH agent

```bash
$ ssh-add simple_aws_key
```

### 2. Decrypt all encrypted terraform files

Sensitive terraform configuration is stored and checked into Github as encrypted files using
[ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). These files are decrypted locally and
git-ignored for local development. Before doing any development, run `./decrypt path-to-your-vault-file aws-account` to
make sure to decrypt the latest versions of the encrypted ansible vault files in this directory.

You can omit the second argument to decrypt all vault files in the terraform directory.

For example:

```bash
$ cd terraform

$ ./decrypt ~/.vault_password bangladesh

Decrypting bangladesh/bd.simple.org.chain.pem.vault to bangladesh/bd.simple.org.chain.pem
Decrypting bangladesh/bd.simple.org.pem.vault to bangladesh/bd.simple.org.pem
Decrypting bangladesh/bd.simple.org.private_key.pem.vault to bangladesh/bd.simple.org.private_key.pem
Decrypting bangladesh/terraform.tfvars.vault to bangladesh/terraform.tfvars

$ ./decrypt ~/.vault_password

Decrypting bangladesh/bd.simple.org.chain.pem.vault to bangladesh/bd.simple.org.chain.pem
Decrypting bangladesh/bd.simple.org.pem.vault to bangladesh/bd.simple.org.pem
Decrypting bangladesh/bd.simple.org.private_key.pem.vault to bangladesh/bd.simple.org.private_key.pem
Decrypting bangladesh/terraform.tfvars.vault to bangladesh/terraform.tfvars
Decrypting development/simple.org.chain.pem.vault to development/simple.org.chain.pem
Decrypting development/simple.org.pem.vault to development/simple.org.pem
Decrypting development/simple.org.private_key.pem.vault to development/simple.org.private_key.pem
Decrypting development/terraform.tfvars.vault to development/terraform.tfvars
```

Even if you've already decrypted these files, it's a good idea to do this again, as the contents of the encrypted files
may have changed since you last decrypted them.

#### Deploying your own instance of Simple?

If you are using not a part of the Simple engineering team, and you are deploying your own instance of
Simple, you should create your own ansible-vault password. See [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
documentation for more details on how to do this.

### 3. Navigate to the AWS environment that you wish to work on.

Each AWS account has a separate subdirectory in the repository. Navigate to the one you wish to work on.

```bash
$ cd bangladesh
```

### 4. Add AWS credentials to your machine

Add the credentials for your AWS account to your `~/.aws/credentials` file. The credentials can be for an IAM user on the
AWS console.

Include the AWS credentials (access key ID and secret access key) in the profile whose name matches the profile declared
in your terraform configuration's `main.tf` file. For example, for `bangladesh` your credentials file should look like
this.

```
[bangladesh]
aws_access_key_id=<YOUR_ACCESS_KEY_ID>
aws_secret_access_key=<YOUR_ACCESS_KEY>
```

See [Amazon's documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more
information how to store your AWS credentials on your machine.

### 5. If you haven't already, initialize Terraform. This command is safe to re-run several times.

```bash
$ terraform init
```

### 6. Verify your changes

After development, run `terraform plan` to check whether the execution plan for your set of changes matches your
expectations without making any changes to real resources.

```bash
$ terraform plan
```
### 7. Encrypt any changed secrets

If you modify a decrypted file during development, re-encrypt all files and check them into the codebase. You can use
the `encrypt` script, which works like the `decrypt` script from Step 2.

```bash
$ cd ..
$ ./encrypt ~/.vault_password bangladesh
$ git add **/*.vault
$ git commit -m 'Update Bangladesh terraform secrets'
```

Note that the `encrypt` script will update _all_ vault files, even if you didn't change anything inside. This is
expected, as ansible-vault encryption [is not idempotent](https://github.com/ansible/ansible/issues/10595).

### 8. Apply

Once you are confident with the execution plan, run `terraform apply` to apply your changes to the AWS environment.

```bash
$ terraform apply
```

## Setting Up A New AWS Account

If you are setting up a new AWS account to be managed by terraform (eg. a Simple Server instance in a new country),
follow these instructions. This setup needs to be run only once per AWS account.

### 1. Set up your AWS account

- Create an AWS account.
- Choose a profile name for the new AWS account. (eg. `ihci`, `bangladesh`)
- Make sure your IAM User has `Administrator` permissions. Get the `Access key ID` and `Secret Access key` for your account and
  put it under `~/.aws/credentials` file on your developer environment. Create this file if doesn't already exist.
```
[profile_name]
aws_access_key_id=<Add Access ID from previous step here>
aws_secret_access_key=<Add Secret Key from previous step here>
```
Refer to [using AWS credential files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more information.
- Create an s3 bucket called `simple-server-<profile_name>-terraform-state`.
- Create a [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html) table
  called `terraform-lock` with `LockID` as primary key.

### 2. Add the new environment to the repository

Run the following script from the `terraform/` directory to create a directory for your new environment. If your new
environment's name is `bangladesh`:

```bash
$ cd terraform
$ ./create_aws_account bangladesh
```

This will create a `bangladesh/` directory with several files.

* `main.tf`
* `terraform.tfvars`
* `certificate.pem`
* `certificate.chain.pem`
* `certificate.private_key.pem`

### 3. Configure the new environment

You will have to edit these files as follows:

* `main.tf`: The main file containing a starting terraform configuration. It includes a demo and production Simple
  environment for your new account. Replace all instances of `sample` with your profile's name. See [Terraform documentation](https://learn.hashicorp.com/collections/terraform/aws-get-started) for more details on how to configure this file.
* `terraform.tfvars`: A git-ignored file where database credentials and other sensitive information is stored. Choose
  any username and password for your databases and enter them into this file. Replace all instances of `sample` with your domain's name and change the certificate file names as well. 
* `certificate.pem`: Place your SSL certificate in this file.
* `certificate.chain.pem`: Place your SSL certificate chain in this file.
* `certificate.private_key.pem`: Place your SSL certificate private key in this file.

### 4. Encrypt secrets

Choose an [Ansible vault password](#vault-password) and store it somewhere on your machine (eg. `~/.vault_password`).

Run the following script from the `terraform` directory to encrypt the sensitive `tfvars` and `pem` files so they can
safely be checked into the repository.

```bash
$ cd terraform
$ ./encrypt ~/.vault_password kerala
```

### Complete!

Your AWS account and deployment repository are now ready for use. Go back to [Getting Started](#getting-started) to
provision your infrastructure.

## Managing environments

- `main.tf` contains several `modules`. Each `module` captures the resources for an env (sandbox, qa, staging etc).
- To setup a new env, you can start with duplicating one of the modules and tweak it to your needs.
- To delete an env, simply remove the module from `main.tf`.

## Helpful commands and information

### Vault password

Sensitive terraform configuration is stored and checked into Github as encrypted files using
[ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). These files are decrypted locally and
git-ignored for local development. In order to decrypt and re-encrypt these files, you will need to use the correct
vault password file.

* For environments managed by the Simple team, the vault password can be found in 1Password.
* Deploying your own instance of Simple? Choose your own vault password when you get started, and save it somewhere
  securely, so it can be re-used to manage your instance of Simple.
  See [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more information on how to create and manage vault passwords.

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
