#!/bin/bash

# Script to open a shell script in a pod, for debugging purposes
# Run with bash run_exec.sh [name of pod]

PODNAME="N/A"
PODNAME=$(kubectl --namespace=mdhdemo get pods | grep $1 | awk '{print $1;}')
echo "Logging into ${PODNAME}"
if [ $PODNAME != "N/A" ]; then
	kubectl --namespace=mdhdemo exec -it $PODNAME -- /bin/bash
else
	echo "INVALID POD NAME"
fi