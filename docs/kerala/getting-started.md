# Getting Started

This guide contains instructions for the eHealth Kerala team to set up an instance of Simple Server.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Initial setup](#initial-setup)
* [Provision infrastructure on AWS](#provision-infrastructure-on-aws)
* [Install required dependencies on AWS infrastructure](#install-required-dependencies-on-aws-infrastructure)
* [Install and launch Simple](#install-and-launch-simple)

## Prerequisites

To launch your instance of Simple, you will need the following:

* An AWS organization account
* Administrator access to the AWS account
* A developer environment with the following dependencies:
  * [Git](https://git-scm.com/)
  * [Terraform](https://www.terraform.io/)
  * [Ansible](https://www.ansible.com/)
  * [Ruby](https://www.ruby-lang.org/en/)

For detailed information on how to install these dependencies, refer to []().

## Initial setup

Clone the [Simple Server](https://github.com/simpledotorg/simple-server) and
[Simple Deployment](https://github.com/simpledotorg/deployment) repositories to your developer environment.

```bash
$ git clone git@github.com:simpledotorg/deployment.git
$ git clone git@github.com:simpledotorg/simple-server.git
```

## Provision infrastructure on AWS

### 1. Set up your AWS account

- Create an IAM user group in the new AWS account called `Provisioners` with the following policies (`My Security Credentials` > `Groups` > `Create new group`)
```
 AmazonEC2FullAccess
 AmazonElastiCacheFullAccess
 AmazonRDSFullAccess
 AmazonS3FullAccess
 AmazonSNSFullAccess
 AmazonDynamoDBFullAccess
 AmazonVPCFullAccess
 AWSCertificateManagerFullAccess
 CloudWatchLogsFullAccess
 IAMFullAccess
```
* Create a user with API-only access and add it to the `Provisioners` group. Keep a note of the user's AWS access ID and secret key

* Add the following profile to the `~/.aws/credentials` file on your developer environment. Create
this file if doesn't already exist.

```
[kerala]
aws_access_key_id=<Add Access ID from previous step here>
aws_secret_access_key=<Add Secret Key from previous step here>
```

 Refer to [using AWS credential files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) for more information.

* Create an S3 bucket named `simple-server-terraform-state`.

* Create a [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html) table
  called `terraform-lock` with `LockID` as primary key.

### 2. Add the new environment to the repository

Run the following script from the `terraform/` directory to create a directory for your new environment.

```bash
$ cd terraform
$ ./create_aws_account kerala
```

This will create a `bangladesh/` directory with several files.

* `main.tf`: The main file containing a starting terraform configuration. It includes a demo and production Simple
  environment for your new account.
* `terraform.tfvars`: A git-ignored file where database credentials and other sensitive information is stored.
* `certificate.pem`: Placeholder for your SSL certificate
* `certificate.chain.pem`: Placeholder for your SSL certificate chain
* `certificate.private_key.pem`: Placeholder for your SSL certificate private key

### 3. Configure the new environment

You will have to edit these files as follows:

* `main.tf`: Update the `profile` value throughout this file from `sample` to `kerala`
* `terraform.tfvars`: Choose any username and password for your databases and enter them into this file.
* `certificate.pem`: Place your SSL certificate in this file.
* `certificate.chain.pem`: Place your SSL certificate chain in this file.
* `certificate.private_key.pem`: Place your SSL certificate private key in this file.

### 4. Choose a vault password

### Vault password

Sensitive terraform configuration is stored and checked into Github as encrypted files using
[ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). These files are decrypted locally and
git-ignored for local development. In order to decrypt and re-encrypt these files, you will need to use a vault password
file.

Choose your own vault password when you get started. This can be any string. We recommend a 256 character password containing letters, numbers, and special characters.

Create a file `~/.vault_password` on your developer environment and place the password into this file.

See [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html) for more information on how to create and manage vault passwords.

### 5. Encrypt secrets

Run the following script from the `terraform` directory to encrypt the sensitive `tfvars` and `pem` files so they can
safely be checked into the repository.

```bash
$ cd terraform
$ ./encrypt ~/.vault_password kerala
```

### 6. Add the master AWS SSH key to your machine

This is the SSH key that will be placed on all provisioned instances for initial access. The key is read off of your
local machine and copied to AWS by terraform.

* Create a keypair. You can use [any resource](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for more information on how to generate an SSH keypair.

```bash
$ ssh-keygen -t ed25519-sk -C "your_email@example.com"
```

* When prompted, enter `simple_aws_key` as the name of the new keypair.

* Add the new key to your SSH agent

```bash
$ ssh-add simple_aws_key
```

### 7. Navigate to the Kerala directory

Each AWS account has a separate subdirectory in the repository. Navigate to the one you wish to work on.

```bash
$ cd kerala
```

### 8. Initialize Terraform. This command is safe to re-run several times.

```bash
$ terraform init
```

### 9. Verify your changes

Run `terraform plan` to check what infrastructure will be provisioned on AWS. Verify that the plan is as expected.

```bash
$ terraform plan
```

:warning: You may encounter an error that looks like the following:
```
Error: Invalid count argument

  on ../modules/simple_server/cloudwatch.tf line 82, in resource "aws_cloudwatch_metric_alarm" "elb_5xx_timeouts":
  82:   count               = var.load_balancer_arn_suffix != "" && var.enable_cloudwatch_alerts ? 1 : 0

The "count" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be created.
To work around this, use the -target argument to first apply only the
resources that the count depends on.
```
To work around this problem,
* Go to the problematic line of code in the repository
* Replace the conditional count with a hard-coded value for now - `count = 1`
* Proceed with the rest of this guide
* After a successful `terraform apply`, undo your temporary changes

### 10. Apply

Once you are confident with the execution plan, run `terraform apply` to apply your changes to the AWS environment.

```bash
$ terraform apply
```

This will provision all the necessary infrastructure for one demo and one production environment of Simple Server.

## Install required dependencies on AWS infrastructure

### 1. Navigate to the
