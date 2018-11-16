## Info
The supp-tools for kubernetes collect basic information from a kubernetes cluster to work on either POD/Container issues or issues 
related to the agent-nodes (agents, minions). The tools were developped to work on AKS Support Requests. But can be used on any other cluster as well, as 
no special dependencies are used.


There are two tools: 
 - aks-supcollection.sh
 - report.sh

## aks-suppcollection.sh
This tool collects all kind of Kubernetes related information (POD, Service, Endpoint, etc.)
All of the information collected are saved in a tar-bal in the folder /tmp as aks-support-collection.tar
 
## report.sh
This tool creates an sosreport on each of the agent-nodes. It collects also the folder /var/log/containers
and gets the kubelet log. All of the information are saved in a tar-ball which is saved in the folder /tmp as aks-report.tar, locally on your 
 
##Requirements
- The report.sh tool expects sosreport installed on each of the nodes (which should be the default on the major distros)
- Systemd needs to be installed 
- In order to run both tools a working kubectl setup is needed to get in touch with the cluster of choice.
- The tools work only in a Linux/Unix environment. On Windows [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) can be used instead 
