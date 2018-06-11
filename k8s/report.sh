#/bin/bash

#create the POD node-report
#It has root access to the agent-vm
cat <<END | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: node-report
  labels:
    app: node-report
spec:
  hostNetwork: true
  hostPID: true
  hostIPC: true
  containers:
  - name: alpine
    image: alpine:latest
    command: ["/bin/sh", "-c", "--"]
    args: ["while true; do sleep 30; done;"]
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /agent-root
      name: root-volume
  volumes:
  - name: root-volume
    hostPath:
      path: /
END
#Sleep for 5 seconds to get the POD deployed
sleep 5

#Run the sosreport tool
#Since we use chroot, sosreport installation is not needed. It is is already installed by default on every agent-vm
TDIR=$(mktemp -d /tmp/aks.XXXXXXXXX)
cd $TDIR

echo "Creating the sosreport"
echo "Please be patient ..."
kubectl exec -t node-report -- chroot /agent-root sosreport -a --batch | grep -A 1 "Your sosreport has been generated and saved in:"  > batch.out
kubectl cp node-report:/agent-root$(sed -e '1d; s/\s*//' batch.out) .

#Collect the container logs
echo "Collecting the container-logs"
kubectl exec -t node-report -- chroot /agent-root tar chf /tmp/container_logs.tar /var/log/containers
kubectl cp node-report:/agent-root/tmp/container_logs.tar .

#Remove the batch.out file
rm batch.out
#Create a tar file and add the sosreport and the container_logs to it 
tar cf /tmp/aks-report.tar *

#Delete the tmp-dir
cd /tmp
rm -fr $TDIR

#Delete the POD node-report
kubectl delete pod node-report

