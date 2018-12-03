#!/bin/bash
cat <<END | kubectl create -f - ;
apiVersion: v1
kind: Pod
metadata:
  name: getsecret
  labels:
    app: getsecret
spec:
  containers:
  - name: alpine
    image: alpine:latest
    command: ["/bin/sh", "-c", "--"]
    args: ["while true; do sleep 30; done;"]
    volumeMounts:
    - mountPath: /kubernetes
      name: etc-kubernetes
  volumes:
  - name: etc-kubernetes
    hostPath:
      path: /etc/kubernetes
END
sleep 3
kubectl exec -t getsecret -- cat /kubernetes/azure.json > azure.json
grep "aadClientId" azure.json > aadClientId.value
grep "aadClientSecret" azure.json > aadClientSecret.value

#Remove quotes from the value
temp=$(cat aadClientId.value | awk '{print $2}')
temp="${temp#\"}"
temp="${temp%\",}"
echo $temp > aadClientId.value

temp=$(cat aadClientSecret.value | awk '{print $2}')
temp="${temp#\"}"
temp="${temp%\",}"
echo $temp > aadClientSecret.value

#Renew/Create Service Principal Secret
az ad sp credential reset --name $(cat aadClientId.value) --password $(cat aadClientSecret.value) --years 2 

kubectl delete pod -l app=getsecret