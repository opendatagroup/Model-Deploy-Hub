#!/bin/bash

out=$(kubectl --namespace=mdhub get svc proxy-public)
for a in $out
do
	count=$((count+1))
	if [[ ${count} == 8 ]]; then
		IP=${a}
	fi
done
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito --disable-gpu "${IP}"