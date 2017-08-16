KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
DIFFERENCE=$(diff -bB  <(cat .user_status | grep -v ".user_status"| sort) <(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
	https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$POD_NAMESPACE/pods \
	| grep "name\": \"jupyter-" | awk '{print $2}' | tr -d ',' | tr -d '\"' | sort))
echo $DIFFERENCE | awk '{print $3;}'