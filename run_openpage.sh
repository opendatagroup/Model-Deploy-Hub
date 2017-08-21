#!/bin/bash

# Script to open hub in browsers

IP=$(kubectl --namespace=mdhdemo get svc | grep proxy-public | awk '{print $3}')
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito --disable-gpu "${IP}"