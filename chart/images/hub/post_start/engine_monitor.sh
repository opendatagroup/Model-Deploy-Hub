#!/bin/bash

function log {
	echo "[${USER}][`date`] - ${*}" >> /srv/post_start/engine_monitor_log.txt
}
log "Began script"

# connecting to fastscore
OUTPUT="N/A"
ERRORCOUNT=0
while [ "$OUTPUT" != "Proxy prefix set" ]
do
	sleep 5
	OUTPUT=$(fastscore connect https://130.211.206.35:30001)
	if [ $ERRORCOUNT -ge 24 ]; then
		# temporary debugging solution, need to find a way to output to log from shell
		log "DEBUG: Failed to connect to fastscore: $OUTPUT"
		break
	else
		ERRORCOUNT=$((ERRORCOUNT+1))
	fi
done

log "Successfully connected to fastscore after $ERRORCOUNT tries"

# config fastscore to 0 engines
OUTPUT="N/A"
ERRORCOUNT=0

while [ "$OUTPUT" != "Configuration updated" ]
do
	sleep 5
	OUTPUT=$(fastscore config set /srv/post_start/config.yml)
	if [ $ERRORCOUNT -ge 24 ]; then
		# temporary debugging solution, need to find a way to output to log from shell
		log "Failed to set fastscore config:\n$OUTPUT"
		break
	else
		ERRORCOUNT=$((ERRORCOUNT+1))
	fi
done

log "Successfully configurated fastscore after $ERRORCOUNT tries"

# delete engine pods if any
# shut down servers



# function to return next available engine

#function returnQueuedEngine {
#
#}
function checkContainers {
	# collect names of currently running notebooks and output in correct order
	KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
	KUBERNETES_SERVICE_HOST=$()
	DIFFERENCE=$(diff -bB  <(cat .user_status | grep -v ".user_status"| sort) <(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
		https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods \
		| grep "name\": \"jupyter-" | awk '{print $2}' | tr -d ',' | tr -d '\"' | sort))
	if [[ $(echo $DIFFERENCE | wc -w) -le 0 ]]; then
		log "No new notebooks - No stopped notebooks"
	elif [ $(echo $DIFFERENCE | wc -w) -ge 4 ]; then
		# TODO: Handle multiple users added/removed in one interval
		log "Multiple users added/removed"
	else
		# extra user in .user_status (user gets deleted) results in (< username)
		#     if Engine == max-1 {delete max, change max-1 from username to max
		# 	  Else open up engine as available
		USERNAME=$($DIFFERENCE | awk '{print $2;}' | tr -d '\n')
		if [[ $DIFFERENCE == *['<']* ]]; then
			log "${USERNAME} has been deleted"
		elif [[ $DIFFERENCE == *['>']* ]]; then
			# user being added and missing in .user_status results in (> jupyter-jackmoore5021)
			#     in this case the engine must be taken off available, env changed to lowest available
			# 	  if lowest available is max, a new engine must be made and set to max
			log "${USERNAME} has been added"
		else
			log "ERROR, no > or < found, result of diff:\n ${DIFFERENCE}"
		fi
	fi
	return
}
while :
do
	checkContainers	
	sleep 2
done










