#!/bin/bash

echo "Starting keepalived"
# force delay for sync configMap mount
sleep  3

KEEPALIVED="keepalived.conf"

echo "Checking for Node specific configuration ${NODE_NAME}.conf"
if [ -f "/vip/${NODE_NAME}.conf" ]; then
    echo "Found node specific configuration. Using ${NODE_NAME}.conf"
    KEEPALIVED="${NODE_NAME}.conf"
else
    echo "Using default configuration ${KEEPALIVED}"
fi 

# Start Keepalived
keepalived -P -D -l -n -f /vip/${KEEPALIVED} -p /tmp/keepalived.pid -r /tmp/vrrp.pid

#
# END OF FILE
#