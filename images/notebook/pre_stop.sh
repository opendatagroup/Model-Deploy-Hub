#!/bin/bash

function add_engine {
	if [ $2 == true ]; then
		sed -n -i "p;8a \      }"  /$HOME/new_config.json
	else
		sed -n -i "p;8a \      },"  /$HOME/new_config.json
	fi
	sed -n -i "p;8a \        \"port\": 8003"  /$HOME/new_config.json
	sed -n -i "p;8a \        \"host\": \"$1\"," /$HOME/new_config.json
	sed -n -i "p;8a \        \"api\": \"engine-x\"," /$HOME/new_config.json
	sed -n -i "p;8a \      {" /$HOME/new_config.json
}

# GET config
RUNNING_ENGINES=$(curl -i -k $ENGINE_ADDRESS/api/1/service/connect/1/config | grep "\"host\": \"engine" | awk '{print $2}' | sed 's/"//g')
# add each engine ignoring engine.id
echo "Running engines: $RUNNING_ENGINES"
ENGINEID=$(cat /$HOME/engine.id)
FIRST=true
# start with empty config
cp -f /$HOME/empty_config.json /$HOME/new_config.json
# fill up with other engines
for engine in $RUNNING_ENGINES; do
	if [[ "$engine" == "engine-$ENGINEID" ]]; then
		# delete engine
		echo "Deleting $engine"
	else
		echo "Adding $engine"
		add_engine $engine $FIRST
		FIRST=false
	fi
done
# if config is empty replace delete the comma in line 8
if [[ $FIRST == true ]]; then
	echo "No engines in config, replacing }, with }"
	sed -i '8s/},/}/' /$HOME/new_config.json
fi

# update config file with engine removed
curl -sSk -X PUT -d @/$HOME/new_config.json -H "Content-Type: application/json" $ENGINE_ADDRESS/api/1/service/connect/1/config
echo "Deleting engine-$ENGINEID deployment"
curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$KUBERNETES_API_NAMESPACE/deployments/engine-$ENGINEID
echo "Deleting engine-$ENGINEID svc"
curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$KUBERNETES_API_NAMESPACE/services/engine-$ENGINEID

#REPLICASET=$(curl -sSk -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$KUBERNETES_API_NAMESPACE/replicasets/ | grep "\"name\": \"engine-$ENGINEID-" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
#echo "Deleting replicaset $REPLICASET"
#curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$KUBERNETES_API_NAMESPACE/replicasets/$REPLICASET
#POD=$(curl -sSk -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$KUBERNETES_API_NAMESPACE/pods | grep "\"name\": \"engine-$ENGINEID-" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
#deleting pod
# curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$KUBERNETES_API_NAMESPACE/pods/$POD







