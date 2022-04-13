# Ethiopia Playbook

## Deployment

First up, make sure you have the specific Ethiopia private vault key to decrypt the secret configuration and credentials. Ask someone on the Simple team, if you're unsure.

Follow the [standalone](../../standalone/README.md) guide for the remaining steps to complete the self-managed deploy.

Currently, the ET releases are made through [Semaphore](https://resolvetosavelives.semaphoreci.com) in the [Simple Server](https://github.com/simpledotorg/simple-server) project.

There are 2 active environments on Ethiopia.

### Demo ([Pipeline](https://github.com/simpledotorg/simple-server/blob/master/.semaphore/ethiopia_demo_deployment.yml))

This is deployed on the RTSL Digital Ocean account.

### Production ([Pipeline](https://github.com/simpledotorg/simple-server/blob/master/.semaphore/ethiopia_production_deployment.yml))
This is deployed on the bare-metal Dell servers in Ethiopia datacenters.

## Guides and Documentation

* [Infrastructure](ethiopia-infrastructure.md)
* [Database Access](ethiopia-database-access.md)
* [Troubleshooting](ethiopia-troubleshooting.md)
* [Install/Update SSL Certificates](ethiopia-ssl-certificates.md)
