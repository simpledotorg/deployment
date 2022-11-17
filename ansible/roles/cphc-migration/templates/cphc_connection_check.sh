#! /usr/bin/bash
# alerts configuration
MIN_FAILURES_FOR_ALERT=2
ALERT_FREQUENCY_MINUTES=5
STATUS_CHECK_FREQUENCY_SECONDS=5
ALERT_MESSAGE="Unable to connect CPHC VPN"
# end alerts configuration

CONSECUTIVE_FAILURES=0
LAST_ALERT_TIME=0

slack_alert () {
  curl -X POST -H 'Content-type: application/json' --data '{"text":"$1"}' {{ cphc_vpn.alerts_webhook_url }}
}

vpn_login () {
  naclient login -profile {{ cphc_vpn.profile }} -user {{ cphc_vpn.username }} -password '{{ cphc_vpn.password }}' <<< y
}

echo_with_time () {
  echo "$(date '+TIME:%H:%M:%S') $1"
}

while true; do
  naclient status
  if [ $? -eq 1 ]; then
    echo_with_time "VPN is connected"
  else
    CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
    vpn_login
    if [ $? -eq 1 ]; then
      echo_with_time "Successfully connected to VPN"
      CONSECUTIVE_FAILURES=0
      LAST_ALERT_TIME=0
    elif [ $CONSECUTIVE_FAILURES -gt $MIN_FAILURES_FOR_ALERT ] && [ $(($(date +%s) - $LAST_ALERT_TIME)) -ge $(( ALERT_FREQUENCY_MINUTES * 60 )) ]; then
      echo_with_time $ALERT_MESSAGE
      slack_alert $ALERT_MESSAGE
      LAST_ALERT_TIME=$(date +%s)
    fi
  fi
  sleep $STATUS_CHECK_FREQUENCY_SECONDS
done

