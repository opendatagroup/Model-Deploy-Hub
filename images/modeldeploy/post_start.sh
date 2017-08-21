#!/bin/bash

function log {
	echo "[${USER}][`date`] - ${*}" >> ../logs.txt
}

function add_engine {
	if [ $2 == true ]; then
		log "first engine $2"
		sed -n -i "p;8a \      }"  ../new_config.json
	else
		log "comma added $2"
		sed -n -i "p;8a \      },"  ../new_config.json
	fi
	sed -n -i "p;8a \        \"port\": 8003"  ../new_config.json
	sed -n -i "p;8a \        \"host\": \"$1\"," ../new_config.json
	sed -n -i "p;8a \        \"api\": \"engine-x\"," ../new_config.json
	sed -n -i "p;8a \      {" ../new_config.json
}

# copy starter notebooks to persisten volume
cp -Rf /$HOME/.starterNotebooks/. /$HOME/work

# collect current running engines
RUNNING_ENGINES=$(curl -i -k $ENGINE_ADDRESS/api/1/service/connect/1/config | grep "\"host\": \"engine" | awk '{print $2}' | sed 's/"//g')
# start with empty config and add current running engines
log "Prior empty_config.json: \n$(cat ../empty_config.json)"
log "RUNNING_ENGINES - $RUNNING_ENGINES"

log "newconfig $(cp -f ../empty_config.json ../new_config.json)"
FIRST=true
for engine in $RUNNING_ENGINES; do
	log "ADDING $engine"
	add_engine "$engine" $FIRST
	FIRST=false
done
# find an engine ID
NEW_ENGINE_NUM=1
while [[ $(echo $RUNNING_ENGINES | grep -c "engine-$NEW_ENGINE_NUM") != 0 ]]
do
	NEW_ENGINE_NUM=$((NEW_ENGINE_NUM+1))
done
log "output if while statement $($RUNNING_ENGINES | grep -c "engine-$NEW_ENGINE_NUM")"
log "NEW_ENGINE_NUM = $NEW_ENGINE_NUM"
echo $NEW_ENGINE_NUM > ../engine.id
# edit engine_svc and engine_deploy
sed "s/-X/-${NEW_ENGINE_NUM}/g" ../engine_deploy_empty.json > ../engine_deploy.json
sed "s/-X/-${NEW_ENGINE_NUM}/g" ../engine_svc_empty.json > ../engine_svc.json
rm -f ../engine_deploy_empty.json
rm -f ../engine_svc_empty.json
add_engine "engine-${NEW_ENGINE_NUM}" $FIRST
# function to add engine
curl -sSk -X POST -d @../engine_deploy.json -H "Content-Type: application/json" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$KUBERNETES_API_NAMESPACE/deployments
curl -sSk -X POST -d @../engine_svc.json -H "Content-Type: application/json" -H "Authorization: Bearer $KUBERNETES_API_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$KUBERNETES_API_NAMESPACE/services
curl -sSk -X PUT -d @../new_config.json -H "Content-Type: application/json" $ENGINE_ADDRESS/api/1/service/connect/1/config



