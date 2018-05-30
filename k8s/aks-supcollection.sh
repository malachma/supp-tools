#!/bin/bash

cat << EOF
This tool performs a collection of some relevant information of a Kubernetes cluster.
The output is stored in a file named aks-support-collection.tar in location /tmp
EOF

TDIR=$(mktemp -d /tmp/aks.XXXXXXXXX)
cd $TDIR

kubectl version > version.txt 2>&1
kubectl get nodes -o wide > nodes.txt 2<&1
kubectl describe nodes > nodes-describe.txt 2<&1

kubectl get --all-namespaces certificatesigningrequests -o wide > certificatesingrequests.txt 2<&1

kubectl get --all-namespaces clusterrolebindings -o wide > clusterrolebinding.txt 2<&1

  kubectl get --all-namespaces clusterroles -o wide -> clusterroles.txt 2<&1


  kubectl get --all-namespaces componentstatuses -o wide > componentstatuses.txt 2<&1

  kubectl get --all-namespaces configmaps -o wide > configmaps.txt 2<&1

  kubectl get --all-namespaces controllerrevisions -o wide > controllerrevisions.txt 2<&1

  kubectl get --all-namespaces cronjobs -o wide > coronjobs.txt 2<&1

  kubectl get --all-namespaces customresourcedefinition -o wide > customresourcedefinition.txt 2<&1

  kubectl get --all-namespaces daemonsets -o wide > daemonsets.txt 2<&1

  kubectl get --all-namespaces deployments -o wide > deployments.txt 2<&1

  kubectl get --all-namespaces endpoints -o wide > endpoints.txt 2<&1

  kubectl get --all-namespaces events -o wide > events.txt 2<&1

  kubectl get --all-namespaces horizontalpodautoscalers -o wide > horizontalpodautoscalers.txt  2<&1

  kubectl get --all-namespaces ingresses -o wide > ingress.txt 2<&1

  kubectl get --all-namespaces jobs -o wide > jobs.txt 2<&1

  kubectl get --all-namespaces limitranges -o wide > limitranges.txt 2<&1

  kubectl get --all-namespaces namespaces -o wide > namespaces.txt 2<&1

  kubectl get --all-namespaces networkpolicies -o wide > networkpolicies.txt 2<&1

  kubectl get --all-namespaces persistentvolumeclaims -o wide > persistentvolumeclaims.txt 2<&1

  kubectl get --all-namespaces persistentvolumes -o wide > persistentvolumes.txt 2<&1

  kubectl get --all-namespaces poddisruptionbudget -o wide > poddisruptionbudget.txt 2<&1

  kubectl get --all-namespaces pods -o wide > pods.txt 2<&1

  kubectl get --all-namespaces podsecuritypolicies -o wide > podsecuritypolicies.txt  2<&1

  kubectl get --all-namespaces podtemplates -o wide > podtemplates.txt 2<&1

  kubectl get --all-namespaces replicasets -o wide > replicasets.txt 2<&1

  kubectl get --all-namespaces replicationcontrollers -o wide > replicationcontrollers.txt 2<&1

  kubectl get --all-namespaces resourcequotas -o wide > resourcequoatas.txt 2<&1

  kubectl get --all-namespaces rolebindings -o wide > rolebindings.txt 2<&1

  kubectl get --all-namespaces roles -o wide > roles.txt 2<&1

  kubectl get --all-namespaces serviceaccounts -o wide > serviceaccounts.txt 2<&1

  kubectl get --all-namespaces services -o wide > services.txt 2<&1

  kubectl get --all-namespaces statefulsets -o wide > statefulsets.txt 2<&1

  kubectl get --all-namespaces storageclasses -o wide > storageclasses.txt 2<&1

mkdir failed-pods
cd failed-pods

for failedpods in $(kubectl get pods --all-namespaces | awk '$4 != "Running" {if (NR!=1) {print $1":"$2}}'); do podcontainers=$(kubectl get pod $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) -o jsonpath={.status.containerStatuses[*].name}); for container in $(echo $podcontainers); do kubectl logs $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) -c $container > $failedpods-$container.txt; done; done

for failedpods in $(kubectl get pods --all-namespaces | awk '$4 != "Running" {if (NR!=1) {print $1":"$2}}');do kubectl describe pod $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) > failedpod-describe_$failedpods.txt ; done
cd $TDIR

tar -cf $TDIR/aks-support-collection.tar *
mv $TDIR/aks-support-collection.tar /tmp
rm -fr $TDIR 

