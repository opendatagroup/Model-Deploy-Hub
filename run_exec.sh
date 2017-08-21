#!/bin/bash


PODNAME="N/A"
PODNAME=$(kubectl --namespace=local get pods | grep $1 | awk '{print $1;}')
echo "Logging into ${PODNAME}"
if [ $PODNAME != "N/A" ]; then
	kubectl --namespace=mdhub exec -it $PODNAME -- /bin/bash
else
	echo "INVALID POD NAME"
fi