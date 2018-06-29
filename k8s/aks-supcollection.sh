#!/bin/bash


#Define the spinner functionality
#The function is from --> https://github.com/tlatsas/bash-spinner/blob/master/README
function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}


#In order to have both wide and json output declare an array
declare -a OUT=('wide' 'json')

#All commands are stored in an associative array to simplify maintenance 
declare -A commands=( 
  ['Get version']='kubectl version > version.txt.$OUTPUT 2>&1'
  ['Get nodes']='kubectl get nodes -o $OUTPUT > nodes.txt.$OUTPUT 2<&1'
  ['Describe nodes']='kubectl describe nodes > nodes-describe.txt.$OUTPUT 2<&1'
  ['Get certificatesignrequests']='kubectl get --all-namespaces certificatesigningrequests -o $OUTPUT > certificatesingrequests.txt.$OUTPUT 2<&1'
  ['Get clusterrolebindings']='kubectl get --all-namespaces clusterrolebindings -o $OUTPUT > clusterrolebinding.txt.$OUTPUT 2<&1'
  ['Get clusterroles']='kubectl get --all-namespaces clusterroles -o $OUTPUT -> clusterroles.txt.$OUTPUT 2<&1'
  ['Get componentstatus']='kubectl get --all-namespaces componentstatuses -o $OUTPUT > componentstatuses.txt.$OUTPUT 2<&1'
  ['Get configmaps']='kubectl get --all-namespaces configmaps -o $OUTPUT > configmaps.txt.$OUTPUT 2<&1'
  ['Get controllerrevisions']='kubectl get --all-namespaces controllerrevisions -o $OUTPUT > controllerrevisions.txt.$OUTPUT 2<&1'
  ['Get cronjobs']='kubectl get --all-namespaces cronjobs -o $OUTPUT > coronjobs.txt.$OUTPUT 2<&1'
  ['Get customsourcedefinition']='kubectl get --all-namespaces customresourcedefinition -o $OUTPUT > customresourcedefinition.txt.$OUTPUT 2<&1'
  ['Get daemonsets']='kubectl get --all-namespaces daemonsets -o $OUTPUT > daemonsets.txt.$OUTPUT 2<&1'
  ['Get deployments']='kubectl get --all-namespaces deployments -o $OUTPUT > deployments.txt.$OUTPUT 2<&1'
  ['Get endpoints']='kubectl get --all-namespaces endpoints -o $OUTPUT > endpoints.txt.$OUTPUT 2<&1'
  ['Get events']='kubectl get --all-namespaces events -o $OUTPUT > events.txt.$OUTPUT 2<&1'
  ['Get horizontalpodautoscalers']='kubectl get --all-namespaces horizontalpodautoscalers -o $OUTPUT > horizontalpodautoscalers.txt.$OUTPUT  2<&1'
  ['Get ingresses']='kubectl get --all-namespaces ingresses -o $OUTPUT > ingress.txt.$OUTPUT 2<&1'
  ['Get jobs']='kubectl get --all-namespaces jobs -o $OUTPUT > jobs.txt.$OUTPUT 2<&1'
  ['Get limitranges']='kubectl get --all-namespaces limitranges -o $OUTPUT > limitranges.txt.$OUTPUT 2<&1'
  ['Get namespaces']='kubectl get --all-namespaces namespaces -o $OUTPUT > namespaces.txt.$OUTPUT 2<&1'
  ['Get networkpolicies']='kubectl get --all-namespaces networkpolicies -o $OUTPUT > networkpolicies.txt.$OUTPUT 2<&1'
  ['Get persistenvolumeclaims']='kubectl get --all-namespaces persistentvolumeclaims -o $OUTPUT > persistentvolumeclaims.txt.$OUTPUT 2<&1'
  ['Get persistentvolumes']='kubectl get --all-namespaces persistentvolumes -o $OUTPUT > persistentvolumes.txt.$OUTPUT 2<&1'
  ['Get poddisruptionbudget']='kubectl get --all-namespaces poddisruptionbudget -o $OUTPUT > poddisruptionbudget.txt.$OUTPUT 2<&1'
  ['Get PODs']='kubectl get --all-namespaces pods -o $OUTPUT > pods.txt.$OUTPUT 2<&1'
  ['Get podsecuritypolicies']='kubectl get --all-namespaces podsecuritypolicies -o $OUTPUT > podsecuritypolicies.txt.$OUTPUT  2<&1'
  ['Get podtemplates']='kubectl get --all-namespaces podtemplates -o $OUTPUT > podtemplates.txt.$OUTPUT 2<&1'
  ['Get replicasets']='kubectl get --all-namespaces replicasets -o $OUTPUT > replicasets.txt.$OUTPUT 2<&1'
  ['Get replicationcontrollers']='kubectl get --all-namespaces replicationcontrollers -o $OUTPUT > replicationcontrollers.txt.$OUTPUT 2<&1'
  ['Get resourcequotas']='kubectl get --all-namespaces resourcequotas -o $OUTPUT > resourcequoatas.txt.$OUTPUT 2<&1'
  ['Get rolebindings']='kubectl get --all-namespaces rolebindings -o $OUTPUT > rolebindings.txt.$OUTPUT 2<&1'
  ['Get roles']='kubectl get --all-namespaces roles -o $OUTPUT > roles.txt.$OUTPUT 2<&1'
  ['Get serviceaccounts']='kubectl get --all-namespaces serviceaccounts -o $OUTPUT > serviceaccounts.txt.$OUTPUT 2<&1'
  ['Get services']='kubectl get --all-namespaces services -o $OUTPUT > services.txt.$OUTPUT 2<&1'
  ['Get statefulsets']='kubectl get --all-namespaces statefulsets -o $OUTPUT > statefulsets.txt.$OUTPUT 2<&1'
  ['Get storageclasses']='kubectl get --all-namespaces storageclasses -o $OUTPUT > storageclasses.txt.$OUTPUT 2<&1'
)


cat <<EOF
This tool collects some relevant information from a Kubernetes cluster.
The collection is stored in the tar bundle aks-support-collection_<SR-Number>.tar in the /tmp folder after it has finished.
EOF
echo
echo
#We need an SR number to create the tar bundle name correct
read -p "What is the SR number this collection is associated with? " SRNUMBER

TDIR=$(mktemp -d /tmp/aks.XXXXXXXXX)
cd $TDIR

#Create the collection dir which is used to store any file created, which becomes hand if the tar archive is expanded later
mkdir collection
cd collection

#Get our commands executed and generate both json and wide output
for CMD in "${!commands[@]}"; do
  start_spinner "$CMD"
  for OUTPUT in "${OUT[@]}"; do
    eval ${commands[$CMD]}; 
  done;
  stop_spinner $?
done

#Create a failed-pods directory to store this extra information
mkdir failed-pods
cd failed-pods

start_spinner 'Get failed pods information'
for failedpods in $(kubectl get pods --all-namespaces | awk '$4 != "Running" {if (NR!=1) {print $1":"$2}}'); do podcontainers=$(kubectl get pod $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) -o jsonpath={.status.containerStatuses[*].name}); for container in $(echo $podcontainers); do kubectl logs $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) -c $container > $failedpods-$container.txt.$OUTPUT; done; done

for failedpods in $(kubectl get pods --all-namespaces | awk '$4 != "Running" {if (NR!=1) {print $1":"$2}}');do kubectl describe pod $(echo $failedpods | cut -d':' -f2) -n $(echo $failedpods | cut -d':' -f1) > failedpod-describe_$failedpods.txt.$OUTPUT ; done
stop_spinner $?
cd $TDIR

tar -cf $TDIR/aks-support-collection_$SRNUMBER.tar *
mv $TDIR/aks-support-collection_$SRNUMBER.tar /tmp
rm -fr $TDIR 

echo
echo
echo "The support-collection-bundle is stored in /tmp"
echo "The filename is aks-support-collection_$SRNUMBER.tar"

