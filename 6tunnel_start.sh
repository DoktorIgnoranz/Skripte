#!/bin/bash
IPV6=$(dig +short -t AAAA <Domain>)
PROCS=$(ps aux | grep -v grep | grep -v "/bin/bash" | grep 6tunnel)
PROC_LINES=$(echo $PROCS | wc -l)
echo "Current IPv6: $IPV6"
echo "Lines: $PROC_LINES"
echo "Procs: $PROCS"
echo
if (( $PROC_LINES > 0 )); then
  # 6tunnel open, get current IPv6 of 6tunnel
  # if different kill 6tunnel and restart with new IPv6 address
  echo "Found old 6tunnel instance"
  OLD_IPV6=$(ps aux | grep -P -o '6tunnel -4 5000 \K[0-9a-z:]*')

  if [ "$IPv6" == "$OLD_IPV6" ]; then
    echo "Found new IPv6, restarting"
    killall 6tunnel
    sleep 5s
    6tunnel -4 <Port1> $IPV6 <Port1>
    6tunnel -4 <Port2> $IPV6 <Port2>
    6tunnel -4 <Port3> $IPV6 <Port3>
  fi
else
  echo "Starting 6tunnel"
  6tunnel -4 <Port1> $IPV6 <Port1>
  6tunnel -4 <Port2> $IPV6 <Port2>
  6tunnel -4 <Port3> $IPV6 <Port3>
fi