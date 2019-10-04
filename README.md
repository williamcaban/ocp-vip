# OCP-VIP

Provide VIP capabilities to OpenShift Clusters

# Common OCP VIP Configuration
- Create Project or Namespace
    ```
    $ oc new-project ocp-vip --display-name="OCP VIP Services"
    Already on project "ocp-vip" on server 
    ```

- Create ServiceAccount
    ```
    $ oc create serviceaccount ocp-vip-sa
    serviceaccount/ocp-vip-sa created
    ```

- Assign hostnetwork SCC to ServiceAccount
    ```
    $ oc adm policy add-scc-to-user hostnetwork -z ocp-vip-sa
    securitycontextconstraints.security.openshift.io/hostnetwork added to: ["system:serviceaccount:ocp-vip:ocp-vip-sa"]
    ```

# VIP for OpenShift API and MachineConfigServer

- Edit ConfigMap to reflect enfironment and create ConfigMap
    ```
    oc create -f 10-api-mcs-cm.yaml
    configmap/api-mcs-vip-conf created
    ```
- Create VIP Deployment
    ```
    oc create -f api-mcs-vip-deployment.yaml
    deployment.apps/api-mcs-vip created
    ```
- Validate VIP Pods are running
```
$ oc get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE    IP              NODE                              NOMINATED NODE   READINESS GATES
api-mcs-vip-9dcd6c56d-pzqhp   1/1     Running   0          2m8s   198.18.100.12   master-1.ocp4poc.example.com   <none>           <none>
api-mcs-vip-9dcd6c56d-rwt87   1/1     Running   0          2m8s   198.18.100.13   master-2.ocp4poc.example.com   <none>           <none>
api-mcs-vip-9dcd6c56d-w8xrj   1/1     Running   0          2m8s   198.18.100.11   master-0.ocp4poc.example.com   <none>           <none>
```
- Validate VIP is functional
```
$ ping -c 3 198.18.100.100
PING 198.18.100.100 (198.18.100.100) 56(84) bytes of data.
64 bytes from 198.18.100.100: icmp_seq=1 ttl=64 time=3.59 ms
64 bytes from 198.18.100.100: icmp_seq=2 ttl=64 time=0.226 ms
64 bytes from 198.18.100.100: icmp_seq=3 ttl=64 time=0.184 ms

--- 198.18.100.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.184/1.334/3.593/1.597 ms

$ curl -w"\n" -k https://198.18.100.100:6443/healthz
ok
```

# VIP for OpenShift Ingress
