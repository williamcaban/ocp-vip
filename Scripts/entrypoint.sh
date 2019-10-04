#!/bin/bash

echo "Starting keepalived"
# force delay for sync configMap mount
sleep  3

# Start Keepalived
keepalived -P -D -l -n -f /vip/keepalived.conf -p /tmp/keepalived.pid -r /tmp/vrrp.pid

#
# END OF FILE
#