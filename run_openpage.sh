#!/bin/bash

IP=$(kubectl --namespace=mdhub get svc | grep proxy-public | awk '{print $3}')
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito --disable-gpu "${IP}"