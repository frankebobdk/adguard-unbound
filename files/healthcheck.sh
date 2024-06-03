#!/bin/sh

# Check if unbound is running
pgrep unbound > /dev/null
if [ $? -ne 0 ]; then
    echo "unbound is not running!"
    exit 1
fi

# Check if AdGuardHome is running
pgrep AdGuardHome > /dev/null
if [ $? -ne 0 ]; then
    echo "AdGuardHome is not running!"
    exit 1
fi

# Check if Cloudflared is running
pgrep cloudflared > /dev/null
if [ $? -ne 0 ]; then
    echo "Cloudflared is not running!"
    exit 1
fi

# Check if Stubby is running
pgrep stubby > /dev/null
if [ $? -ne 0 ]; then
    echo "Stubby is not running!"
    exit 1
fi

echo "All services are running!"
exit 0
