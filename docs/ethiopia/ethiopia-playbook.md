## Ethiopia Playbook

### Deployment

First up, make sure you have the specific Ethiopia private vault key to decrypt the secret configuration and credentials. Ask someone on the Simple team, if you're unsure.

Follow the [standalone](../../standalone/README.md) guide for the remaining steps to complete the self-managed deploy.

Currently, the ET releases are made through [Semaphore](https://resolvetosavelives.semaphoreci.com) in the [Simple Server](https://github.com/simpledotorg/simple-server) project.

There are 2 active environments on Ethiopia.

##### Demo ([Pipeline](https://github.com/simpledotorg/simple-server/blob/master/.semaphore/ethiopia_demo_deployment.yml))

This is deployed on the RTSL Digital Ocean account.

##### Production ([Pipeline](https://github.com/simpledotorg/simple-server/blob/master/.semaphore/ethiopia_production_deployment.yml))
This is deployed on the bare-metal Dell servers in Ethiopia datacenters.

### Contigency Plan

When something goes wrong on the self-managed standalone Ethiopia production servers.

#### Notes on configuration:

##### IP Addresses

The two Ethiopia production servers are accessible through public IP addresses as well as internal IP addresses if you
are in the network.

```
Box 1:
  Public IP:   197.156.66.181
  Internal IP: 172.19.0.241
Box 2:
  Public IP:   197.156.66.178
  Internal IP: 172.19.0.240
```

When managing the production servers from outside the internal network, the [`production`](../standalone/hosts/ethiopia/production)
hosts file should be used with `make`/`ansible` commands.

When managing the production servers from inside the internal network, the [`production-internal`](../standalone/hosts/ethiopia/production-internal)
hosts file can be used with `make`/`ansible` commands.

![Ethiopia Server Topography](ethiopia-server-topography.png)
This diagram can be edited [here](https://docs.google.com/drawings/d/1iEGHXp1xEOsAVg8zKHnIB17sQHRZdeES9XDjacTSTFA/edit).

##### Load balancing:
- Both instances run an instance of HAProxy. `api.et.simple.org` currently points to `Box 1`. The second box's load balancer
is for redundancy and is not pointed to by a DNS. It is however configured to talk to the webservers already.

##### Web server and sidekiq:
- Both boxes run an instance of the Rails webserver and sidekiq (for background job processing). At all times, these services need to talk to:
    - Primary Postgres DB
    - Redis

##### Postgres:
- Both boxes run an instance of postgres. Postgres on `Box 1` is the primary database. `Box 2` is a hot standby, which can be
  quickly promoted to primary in a contingency.

##### Logs:

All logs are shipped to `Box 2`. DB backups are periodically shipped to Box 2 as well.

#### If `Box 1` dies

- Promote postgres replica on `Box 2` to become master; Change rails config to talk to postgres on `Box 2`.
    - (TODO: Add steps/commands here)
- Update Rails and Sidekiq config to talk to redis on `Box 2`.
- Setup monitoring daemons (grafana, prometheus) to run on `Box 2`.
- Point `api.et.simple.org` DNS in cloudflare to `Box 2`.

#### If `Box 2` dies
- Nothing critical is affected, `simple-server` will continue to run smoothly. Postgres replication, logshipping will stop.
