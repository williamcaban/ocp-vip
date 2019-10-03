#!/bin/bash

TARGET_IP="localhost"

API_HEALTHZ=`curl -o /dev/null -s -w "%{http_code}" -k https://${TARGET_IP}:6443/healthz`
MCS_HEALTHZ=`curl -o /dev/null -s -w "%{http_code}" -k https://${TARGET_IP}:22623/healthz`

if [ "${API_HEALTHZ}" -eq "200" ] && [ "${MCS_HEALTHZ}" -eq "200" ]; then
    exit 0
else
    exit 1
fi