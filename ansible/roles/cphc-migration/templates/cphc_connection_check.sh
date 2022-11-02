#! /usr/bin/bash

naclient status;
if [ $? -eq 1 ];
then echo VPN is connected;
else
  naclient login -profile {{ cphc_vpn.profile }} -user {{ cphc_vpn.username }} -password '{{ cphc_vpn.password }}' <<< y
  if [ $? -eq 1 ];
    then echo Sucessfully connected to VPN;
    else curl -X POST -H 'Content-type: application/json' --data '{"text":"Unable to connect CPHC VPN"}' {{ cphc_vpn.alerts_webhook_url }};
  fi
fi
