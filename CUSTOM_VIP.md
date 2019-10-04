# Creating custom VIP

## Creating the VIP Configuration

Create MachineConfig with the configuration for `keepalived.conf`. Each one of the `keys` in the data section will be a file under `/vip` inside the VIP container. For example, a key with the name of `key_name` will end up as `/vip/key_name`.

The resulting files are read only files. When using a key to provide a track script, the `script` statement must take this into consideration to be able to execute it. For example, using the `/bin/sh -c /vip/key_name` to run the track script.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-vip-conf
  namespace: ocp-vip
data:
  keepalived.conf: |
    global_defs {
      router_id ocp-vip
    }
    vrrp_script probe_script {
      script "/bin/sh -c /vip/probe.sh"
      interval 10
      weight 5
      rise 1
    }
    vrrp_instance VIP {
      virtual_router_id 51
      advert_int 1
      priority 100
      state MASTER
      interface ens3
      virtual_ipaddress {
        198.18.100.201 dev ens3
      }
      track_script {
        probe_script
      }
    }
  probe.sh: |
    #!/bin/bash

    TARGET_IP="localhost"

    OCP_INGRESS_HEALTHZ=`curl -o /dev/null -s -w "%{http_code}" -k https://${TARGET_IP}:1936/healthz`

    if [ "${OCP_INGRESS_HEALTHZ}" -eq "200" ]; then
        exit 0
    else
        exit 1
    fi
```

## Creating the VIP Deployment

The Deployment use AntiAffinity rules to prevent more than one copy of the same VIP from running in the same Node. Consider the use of NodeSelectors and Tollerations if there is a need to create the VIP in Nodes while they are not in a Ready state. 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-vip
  labels:
    app: custom-vip
    vip: custom-vip
  namespace: ocp-vip
spec:
  replicas: 3
  selector:
    matchLabels:
      app: custom-vip
      vip: custom-vip
  template:
    metadata:
      labels:
        app: custom-vip
        vip: custom-vip
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: vip
                operator: In
                values:
                - custom-vip
            topologyKey: kubernetes.io/hostname
      containers:
      - name: ocp-vip
        image: quay.io/wcaban/ocp-vip
        imagePullPolicy: Always
        command: [ "/entrypoint.sh" ]
        securityContext:
          privileged: true
        volumeMounts:
        - name: vip-configuration
          mountPath: /vip
      volumes:
        - name: vip-configuration
          configMap:
            name: custom-vip-conf
      restartPolicy: Always
      resources:
        requests:
          cpu: 200m
          memory: 100Mi
      hostNetwork: true
      serviceAccountName: ocp-vip-sa
      terminationGracePeriodSeconds: 30
#      nodeSelector:
#        kubernetes.io/os: linux
#        node-role.kubernetes.io/master: ""
#      tolerations:
#      - effect: NoSchedule
#        key: node.kubernetes.io/memory-pressure
#        operator: Exists
#      - effect: NoExecute
#        key: node.kubernetes.io/unreachable
#        operator: Exists
#        tolerationSeconds: 300
#      - effect: NoExecute
#        key: node.kubernetes.io/not-ready
#        operator: Exists
#        tolerationSeconds: 300
```