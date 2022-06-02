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

- Make sure your IAM User has `Administrator` permissions. Get the `Access key ID` and `Secret Access key` for your account and
put it under `~/.aws/credentials` file on your developer environment. Create this file if doesn't already exist.
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

Run the following script from the `terraform/` directory of the `deployment` repository to create a directory for your
new environment.

```bash
$ cd deployment
$ cd terraform
$ ./create_aws_account kerala
```

This will create a `kerala/` directory with several files.

* `main.tf`: The main file containing a starting terraform configuration. It includes a demo and production Simple
  environment for your new account.
* `terraform.tfvars`: A git-ignored file where database credentials and other sensitive information is stored.
* `certificate.pem`: Placeholder for your SSL certificate
* `certificate.chain.pem`: Placeholder for your SSL certificate chain
* `certificate.private_key.pem`: Placeholder for your SSL certificate private key

### 3. Configure the new environment

You will have to edit these files as follows:

* `main.tf`: Update the `profile` value throughout this file from `sample` to `kerala`. Remove the
  `module "simple_server_sample_demo"` block if you do not wish to set up a demo environment.
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

### 1. Navigate to the Ansible directory

Navigate to the `ansible` directory in the `deployment` repository

```bash
$ cd ansible
```

### 2. Initialize Ansible

```bash
$ ansible-galaxy install requirements.yml
```

### 3. Create the following files for your new environment

* `group_vars/kerala-production` - File containing some environment-specific Ansible variables
* `hosts.kerala-production` - Host file containing IP addresses of servers
* `roles/simple-server/files/.env.kerala-production` - Encrypted file containing environment variables and application secrets
* `roles/common/ssh_keys/kerala-production/` - Directory containing SSH keys to be placed in the environment for developer access
* `roles/passenger/files/etc/nginx/sites-available/simple.org-kerala-production` - Nginx configuration file for the Nginx web
  servers placed on each EC2 instance

### 4. Configure the new environment

Populate the new files you've created with appropriate configurations. Use any of the existing files as a reference to
get started, and then customize for your new environment. Notably, be sure to update the following parameters:

* Set the environment name in the `group_vars` file to  `kerala-production`
* Add the IP addresses of your EC2 instances (created in the steps above) to the `hosts` file
* Choose what domain you'd like Simple to be hosted at. Add the domain to the `.env` and `simple.org-` Nginx files
* Add SSH keys for all authorized technical staff to the `ssh_keys/kerala-production` directory. Be sure to add your own SSH key as well.
* Configure the environment variables in the `.env.kerala-production` file. Contact the Simple team
  for support on how to configure this file.

### 5. Deploy the configuration

Run a deployment with

```
ansible-playbook -v --vault-id /path/to/password_file deploy.yml -i hosts.kerala-production
```

This will configure your EC2 instances with all the necessary dependencies to run Simple.

## Install and launch Simple

### 1. Navigate to the Simple Server repository

```bash
$ cd simple-server
```

### 2. Install required ruby dependencies

```bash
$ bundle install
```

### 3. Create a config file

Create a new file in `config/deploy/kerala/production.rb` for the new environment. Populate the new config file with relevant IP address info. Use an existing file for reference. For example,
the configuration for a deployment with two EC2 instances may look like:
```
server "ec2-12-111-34-45.ap-south-1.compute.amazonaws.com", user: "deploy", roles: %w[web app db cron whitelist_phone_numbers seed_data]
server "ec2-12-222-67-89.ap-south-1.compute.amazonaws.com", user: "deploy", roles: %w[web sidekiq]
```

The first server runs the web application and cron tasks, the second server runs Sidekiq to process background jobs. Use
the URLs of your EC2 instances from the first steps in this guide to populate this file.

### 4. Install Sidekiq

A one-time installation of Sidekiq is required in new environments. Run the following command:

```bash
bundle exec cap kerala:production sidekiq:install
```

### 5. Deploy

Install and run Simple Server on your servers by running the following command.

```bash
bundle exec cap kerala:production deploy
```

This may take a long time for the first deployment, since several dependencies (like Ruby) need to be installed.
Subsequent deployments will be much faster.

### 6. Set up the Simple database

Run the following commands to set up the Simple database.

```bash
$ bundle exec cap kerala:production deploy:rake task="db:schema:load"
```

### 7. Create a power user account

Create a power user (administrator) account for yourself to log into the Simple Server dashboard

```bash
$ bundle exec cap kerala:production deploy:rake task="create_admin_user[<your name>,<your email address>,<your password>]"
```

### 8. Configure DNS

Find the URL of your AWS Load Balancer on the [AWS Console](https://ap-south-1.console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName).

Create a `CNAME` record on your DNS provider that points your chosen domain (eg. simple.kerala.gov.in) to the AWS Load Balancer URL.

### 9. Verify

Visit your chosen domain in a web browser. You should be directed to the Simple Dashboard. Log in with your
power user account and you should be signed into the Simple dashboard.
