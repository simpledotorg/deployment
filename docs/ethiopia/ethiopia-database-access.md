# Database Access

The data stored by Simple Server can be accessed directly through a database console if necessary.

> Warning: We recommend using direct database access only to _read_ data. Do not modify any data through direct
> database access, as this this could damage the consistency of the data.

To open a database console, first fetch the latest updates to the `simple-server` repository

```bash
cd ~/simple-server
git checkout master
git pull --rebase origin master
bundle install
```

Next, run the following Capistrano command to open a database console

```bash
bundle exec cap ethiopia:production rails:dbconsole
```
