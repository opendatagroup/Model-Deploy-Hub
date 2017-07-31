#!/bin/bash


PODNAME="N/A"
if [ "$1" == "hub" ]; then
	out=$(kubectl --namespace=mdhub get pods)
	for a in $out
	do
		if [[ ${a} == h* ]]; then
			PODNAME=${a}
		fi
	done
else
	PODNAME="jupyter-jackmoore5021"
fi
if [ $PODNAME != "N/A" ]; then
	kubectl --namespace=mdhub exec -it $PODNAME -- /bin/bash
fi