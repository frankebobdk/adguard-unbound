#!/bin/ash

unbound -c /opt/unbound/unbound.conf
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start unbound: $status"
  exit $status
fi

/opt/adguardhome/AdGuardHome -c /opt/adguardhome/conf/AdGuardHome.yaml -w /opt/adguardhome/work --no-check-update
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start AdGuardHome: $status"
  exit $status
fi

# Start Cloudflared
cloudflared tunnel --config /opt/cloudflared/config.yml run
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Cloudflared: $status"
  exit $status
fi

# Wait for all background processes to finish
wait
