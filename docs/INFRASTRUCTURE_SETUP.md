# Infrastructure for simple-server

Simple-server requires one instance for the application, and one instance for a postgres database.
These instructions assume using EC2 for the application, and RDS for postgres.

## Description

### App Server
- EC2 - t2.small
- Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-41e9c52e

### RDS
- RDS - t2.micro
- PostgreSQL 10.3-R1

### Provisioning instructions
Before beginning, create an ansible vault for the new environment.

#### RDS
- Click on launch instance
- From the list of databases, choose postgreSQL
- Choose dev/test or production depending on the environment
- Select `PostgreSQL 10.3-R1` for `DB Version engine`
- Select `db.t2.micro` for `DB Instance class`
- Choose the amount of storage needed
- Add a db identifier, it should be unique across all your dbs in that region
- Add a username
- Add a password. Note: It's recommended to immediately add this password to appropriate ansible-vault
- Click next
- Select appropriate VPC, the default vpc is a sensible default.
- Add a dbname
- Launch instance

It will take some time for aws to allocate a host to the database.
The ansible-vault for the environment should be update now with the database details.

```
Tip: You can choose to only show options available for the free tier
```

#### AWS
From the EC2 dashboard, use the following instructions:

- Click launch instance
- Select Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
- Select t2.micro
- Click Next: Configure instance details
- Under network, make sure that the VPC is the same as the one for the RDS instance
- Click Next: Add storage. You can add more storage if needed.
- Click Next: Add Tags. You can add any tags you need. eg. Name=`instance_name`
- Click Next: Configure security groups
- Create a new security group for the new environment
  - Add appropriate name and description
  - Add rule: type => http
  - Add rule: type => https
  - Add rule: Custom TCP
    - port range: 2812
    - source: Anywhere
- Click review and launch.
- Options can be reviewed and changed at this point. If everything is correct, click Launch

#### Configure RDS security group
- If you know your DB's security group, you can skip these above steps
  - From the RDS dashboard, select your database instance
  - Click on the security-group, this will open the security group dashboard with the DB's security group selected.
- Click on Inbound from the security group's details
- Click Edit
- Add Rule:
  - type: PostgreSQL
  - source:
    - choose custom
    - Add your application instance's security group to the text field
    - Tip: The text feild should autocomplete

#### Assign elastic ip to EC2 instance
- From EC2 dashboard, click on Elastic IPs
- Assign a new elastic IP
- Associate IP with the new instance that was provisioned

#### Next steps
The instance can now be setup for deploy.
Follow instructions in [ansible/README.md](ansible/README.md) to setup the instance.
After this, the application can be deployed on this instance.


#### Upgrading the server instance
The server instance can be upgraded on AWS by followning these steps.
These steps however involve a downtime. No downtime deploys can be done by
temporarily changing the hosts files to point the the IP of the new instance,
deploying the playbook and application, and then reassigning the Elastic IP.

1. Create an instance of the desired configuration
2. Re-assign the Elastic-IP
3. Deploy the ansible playbook
4. Deploy application with capistrano

#### Upgrading the DB instance
The DB instance can be upgraded on RDS by following these steps

1. Create an instance of the desired configuration
2. Update .env.production with the new DB configuration
3. Deploy the ansible playbook
4. Restart passenger using capistrano
```bash
bundle exec cap <env> passenger:restart
```
