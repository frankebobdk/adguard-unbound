#!/bin/ash

# Start unbound
echo "Starting unbound..."
unbound -c /opt/unbound/unbound.conf &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start unbound: $status"
  exit $status
fi

# Start AdGuardHome
echo "Starting AdGuardHome..."
/opt/adguardhome/AdGuardHome -c /opt/adguardhome/conf/AdGuardHome.yaml -w /opt/adguardhome/work --no-check-update &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start AdGuardHome: $status"
  exit $status
fi

# Start Cloudflared
echo "Starting Cloudflared..."
cloudflared --config /opt/cloudflared/cloudflared.yml run &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Cloudflared: $status"
  exit $status
fi

# Start Stubby
echo "Starting Stubby..."
stubby -C /opt/stubby/stubby.yml &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Stubby: $status"
  exit $status
fi

# Wait for all background processes to finish
echo "Waiting for all processes to finish..."
wait
