#!/bin/bash

TARGET_IP="localhost"

OCP_INGRESS_HEALTHZ=`curl -o /dev/null -s -w "%{http_code}" -k https://${TARGET_IP}:1936/healthz/ready`

if [ "${OCP_INGRESS_HEALTHZ}" -eq "200" ]; then
    exit 0
else
    exit 1
fi