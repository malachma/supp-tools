#/bin/bash

#Delete the POD node-report. Be sure we have a clean environment
kubectl delete pod -l app=node-report

#Create a tempdir and move into it
TDIR=$(mktemp -d /tmp/aks.XXXXXXXXX)
cd $TDIR

#create the POD node-report
#It has root access to the agent-vm
for agentname in $(kubectl get nodes -o jsonpath={.items[*].metadata.name}); do 
cat <<END | kubectl create -f - ;
apiVersion: v1
kind: Pod
metadata:
  name: node-report-$agentname
  labels:
    app: node-report
spec:
  hostNetwork: true
  nodeSelector:
    kubernetes.io/hostname: $agentname
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

echo "Creating the sosreport"
echo "Please be patient ..."
kubectl exec -t node-report-$agentname -- chroot /agent-root sosreport -a --batch | grep -A 1 "Your sosreport has been generated and saved in:"  > batch-$agentname.out
kubectl cp node-report-$agentname:/agent-root$(sed -e '1d; s/\s*//' batch-$agentname.out) .

#Collect the container logs
echo "Collecting the container-logs"
kubectl exec -t node-report-$agentname -- chroot /agent-root tar chf /tmp/container_logs.tar /var/log/containers
kubectl cp node-report-$agentname:/agent-root/tmp/container_logs.tar container-$agentname-logs.tar

#Get the kublet log. As it is not a POD/Container anymore with 1.9.6 it can only be fetched via journalctl
kubectl exec -t node-report-$agentname -- chroot /agent-root journalctl -u kubelet --no-pager > kubelet-$agentname.log

#Remove the batch.out file
rm batch-$agentname.out
#End the for loop
done

#Create a tar file and add the sosreport and the container_logs to it 
tar cf /tmp/aks-report.tar *
echo "The created aks-report is located in /tmp. the name of the archive is aks-report.tar"
echo "Please pass over the tar archive to the support engineer"
#Delete the tmp-dir
cd /tmp
rm -fr $TDIR

#Delete the POD node-report
kubectl delete pod -l app=node-report
