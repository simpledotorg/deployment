# Terraform Scripts for provisioning AWS

## Pre-requisites
- Create AWS account
- Create a provisioners group with the following policies
  - all ec2 access
  - all rds access
  - all vpc access
  - all s3 access
  - all elastic cache
  - all dynamo db access
- Create a user with api only access under the provisioners group
- Add users access id and secret key to AWS credentials file under an appropriate profile

## TODO Documentation

* Initial manual setup required on AWS
* Managing vars
  * Vars files
  * Add SSL certificates
  * Encrypt them and commit them into repo
* How add a new module for a new environment setup (like sandbox, qa etc.)
* Basic terraform commands
