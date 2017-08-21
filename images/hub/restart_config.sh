#!/bin/bash

# Script to shut down engines and notebooks, and restart the fastscore config file.  To be used after building a new docker container.
# To run, enter the following line
# 		kubectl --namespace=[HUB_NAMESPACE] exec $PODNAME -- [bash /serviceaccount/restart_config.sh]


sleep 5
KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

# Shut down notebooks
NOTEBOOKS=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods | grep "\"name\": \"jupyter-" | awk '{print $2}' | sed "s/[\",]//g")
for NB in $NOTEBOOKS; do
	curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods/$NB
done

# Update config
IP=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/services/proxy-public | grep "ip" | awk '{print $2}' | sed 's/"//g')
curl -sSk -X PUT -d @/srv/empty_config.json -H "Content-Type: application/json" https://$IP:30001/api/1/service/connect/1/config
sleep 5

# Shutdown extra engines (shouldn't be needed if pre_stop.sh works on modeldeploy but included for safety)
function shutDownEngine {
	# $1 is the deployment/svc name
	curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$POD_NAMESPACE/deployments/$1
	curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/services/$1
	# $2 is the pod name
	curl -sSk -X "DELETE" -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods/$2

}
ENGINES=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$POD_NAMESPACE/deployments | grep "\"name\": \"engine-" | awk '{print $2}' |  sed 's/"//g' | sed 's/,//g' | uniq)
for ENGINE in $ENGINES; do
	POD=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods | grep "\"name\": \"$ENGINE-" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | uniq --check-chars=17)
	shutDownEngine $ENGINE $POD	
done