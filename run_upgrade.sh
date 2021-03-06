#!/bin/bash

# Use this bash script to write custom docker images for your hub and notebook

# build and push docker images from images folder
NEWTAG=$(openssl rand -hex 16)
printf "Generating random tag: ${NEWTAG}\n"
printf "Building hub..."
docker build -q -t jackmoore/hub:${NEWTAG} $(pwd)/images/hub/. > trash.txt
printf "DONE!\nBuilding notebook..."
docker build -q -t jackmoore/notebook:${NEWTAG} $(pwd)/images/modeldeploy/. > trash.txt
printf "DONE!\nPushing hub..."
docker push jackmoore/hub:${NEWTAG} > trash.txt
printf "DONE!\nPushing notebook..."
docker push jackmoore/notebook:${NEWTAG} > trash.txt
printf "DONE!\n"

# Replace config.yaml image tags with new images
printf "Replacing image tags in config.yaml file..."
sed -i -e 's/.*tag:.*/        tag: NEWTAG/' $(pwd)/config.yaml
sed -i -e "s/NEWTAG/${NEWTAG}/g" $(pwd)/config.yaml
printf "DONE!\n"
#remove extra file
rm config.yaml-e
# Give docker a second to update
sleep 5
# And upgrade the pods with the new config.yaml file
printf "Upgrading helm chart with new configurations..."
helm upgrade mdhdemo jupyterhub/jupyterhub --version=v0.4 -f config.yaml --timeout=1800 > trash.txt
printf "DONE!\n"

# Collect hub id
HUBID="INVALID ID"
HUBID=$(kubectl --namespace=mdhdemo get pods | grep hub | grep ContainerCreating | awk '{print $1;}')
if [ HUBID == "INVALID ID" ]; then
	echo 'ERROR WITH HUB ID'
	exit 1
fi

# Wait for hub to get up and running
STATUS="ContainerCreating"
printf "Waiting for hub to deploy..."
while [ $STATUS == "ContainerCreating" ]
do
	STATUS=$(kubectl --namespace=mdhdemo get pods ${HUBID} | grep hub | awk '{print $3;}')
	sleep 1
done

# Open web page if running
if [ $STATUS == "Running" ]; then
	printf "DONE!\nOpening web page in incognito mode on chrome..."
	sleep 3
	bash run_openpage.sh
	printf "DONE!\n"
else 
	printf "ERROR (Hub status): ${STATUS}"
fi
rm trash.txt