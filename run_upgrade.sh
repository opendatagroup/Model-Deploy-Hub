#!/bin/bash

# Use this bash script to write custom docker images for your hub and notebook

# To be used
# DOCKERHUBUSER='jackmoore'
# DOCKERHUBIMAGE='hub'
# DOCKERNOTEBOOKUSER='jackmoore'
# DOCKERNOTEBOOKIMAGE='notebook'

# To be used
# OLDTAG=$(grep 'tag:' config.yaml | sed 's/^.*: //')
NEWTAG=$(openssl rand -hex 16)
printf "Generating random tag: ${NEWTAG}\n"
printf "Building hub..."
docker build -q -t jackmoore/hub:${NEWTAG} $(pwd)/chart/images/hub/. > trash.txt
printf "DONE!\nBuilding notebook..."
docker build -q -t jackmoore/notebook:${NEWTAG} $(pwd)/chart/images/modeldeploy/. > trash.txt
printf "DONE!\nPushing hub..."
docker push jackmoore/hub:${NEWTAG} > trash.txt
printf "DONE!\nPushing notebook..."
docker push jackmoore/notebook:${NEWTAG} > trash.txt
printf "DONE!\n"
# docker rmi jackmoore/hub:${OLDTAG}
# docker rmi jackmoore/notebook:${OLDTAG}


printf "Replacing image tags in config.yaml file..."
sed -i -e 's/.*tag:.*/        tag: NEWTAG/' $(pwd)/config.yaml
sed -i -e "s/NEWTAG/${NEWTAG}/g" $(pwd)/config.yaml
printf "DONE!\n"
rm config.yaml-e
# Give docker a second to update
sleep 1
# And upgrade the pods
printf "Upgrading helm chart with new configurations..."
helm upgrade mdhub jupyterhub/jupyterhub --version=v0.4 -f config.yaml --timeout=1800 > trash.txt
printf "DONE!\n"



HUBID="INVALID ID"
out=$(kubectl --namespace=mdhub get pods)
for a in $out
do
	if [[ ${a} == h* ]]; then
		HUBID=${a}
	fi
done
if [ HUBID == "INVALID ID" ]; then
	echo 'ERROR WITH HUB ID'
	exit 1
fi

STATUS="ContainerCreating"
printf "Waiting for hub to deploy..."
while [ $STATUS == "ContainerCreating" ] || [ $STATUS == "Terminating" ]
do
	out=$(kubectl --namespace=mdhub get pods ${HUBID})
	count=0
	for a in $out
	do
		count=$((count+1))
		if [[ ${count} == 8 ]]; then
			STATUS=${a}
		fi
	done
	sleep 5
done
if [ $STATUS == "Running" ]; then
	printf "DONE!\nOpening web page in incognito mode on chrome..."
	bash run_openpage.sh
	printf "DONE!\n"
else 
	printf "ERROR (Hub status): ${STATUS}"
fi

rm trash.txt
