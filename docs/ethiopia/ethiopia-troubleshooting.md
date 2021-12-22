# Ethiopia Troubleshooting

## Debugging server issues

If an Ethiopia server is down, either due to load balancer or other config related issues, it can be helpful to jump on one of the servers to take a look at logs.

For example, if HA Proxy is not working and production is down, here is how you could find more info on what is going on:


Grab one of the ips listed under `webservers` from the [production](/standalone/hosts/ethiopia/production) file, and then ssh in as the ubuntu user:

```
ssh ubuntu@197.156.66.181
```

From there, you'll want to go to `/var/log/`, where most services will be logging their activity. 

```
cd /var/log
# lists files with most recently modified last - this can be helpful to see
# other files you may want to check
ls -ltr
```

At the bottom you will see some output like this:

```
drwxr-xr-x 2 root             adm                  4096 Dec 22 06:25 nginx
-rw-r----- 1 root             adm                124155 Dec 22 21:28 fail2ban.log
-rw------- 1 root             utmp              2145152 Dec 22 21:28 btmp
-rw-rw-r-- 1 root             utmp              4087680 Dec 22 21:29 wtmp
-rw-rw-r-- 1 root             utmp               292584 Dec 22 21:29 lastlog
-rw-r----- 1 syslog           adm               4255952 Dec 22 21:29 ufw.log
-rw-r----- 1 syslog           adm               1178475 Dec 22 21:30 auth.log
-rw-r----- 1 syslog           adm               1368039 Dec 22 21:30 haproxy.log
-rw-r----- 1 syslog           adm               7329713 Dec 22 21:30 kern.log
-rw-r----- 1 syslog           adm               3346400 Dec 22 21:30 syslog
```

Start by 'live tailing' haproxy.log:

```
sudo tail -f haproxy.log
```

Or view the last 3000 lines of haproxy.log

```
sudo tail -n 3000 haproxy.log
```

Scan those logs for things like configuration errors or other things preventing haproxy from starting successfully.

You may also want to check nginx logs - note that they are in their own subdirectory:

```
cd /var/log/nginx
# live tail both error and access logs
sudo tail -f error.log access.log
# view last 3000 lines of both logs to scan for errors
sudo tail -f error.log access.log
# search for the string `error` (case insensitive) in the error.log w/ 4 lines of context
sudo grep -i ERROR error.log -C4
```

The above are just examples of some things to start with, there are lots of other ways to drill down as you search for things.  Check out `man tail` and `man grep` for more details on those commands.



