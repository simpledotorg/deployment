#! /usr/bin/bash

CONSECUTIVE_FAILURES=0
while true; do
  naclient status
  if [ $? -eq 1 ]; then
    echo "$(date '+TIME:%H:%M:%S') VPN is connected"
  else
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    naclient login -profile {{ cphc_vpn.profile }} -user {{ cphc_vpn.username }} -password '{{ cphc_vpn.password }}' <<< y
    if [ $? -eq 1 ]; then
      echo "$(date '+TIME:%H:%M:%S') Successfully connected to VPN"
      CONSECUTIVE_FAILURES=0
    elif [ $CONSECUTIVE_FAILURES -gt 2 ]; then
      curl -X POST -H 'Content-type: application/json' --data '{"text":"Unable to connect CPHC VPN"}' {{ cphc_vpn.alerts_webhook_url }}
    fi
  fi
  sleep 5
done
