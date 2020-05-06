# Setting up Metabase on AWS

The instructions on Metabase docs are already quite good. This document is just a few salient points to assist the docs to fit with our infrastructure.

Refer largely to the Metabase docs and just use this for clarification on a few settings and tweaks.

* In the Quick Launch section, choose a descriptive name, like:

* In the Upload Code section, don't choose the default S3 URL. Download Metabase from here and upload it manually.

* In the Network section after launching the app, select the "Default VPC".


Check:

Visibility: Public
Load Balancer Subnets: Select all
Pulibc IP Address: Yes
Instance Subnets: Select all
Database Subnets: Select all

* In the Database section, set a username and password, and keep the instance type to be `t2.small`

*
