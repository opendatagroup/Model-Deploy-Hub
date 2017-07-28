# Model Deploy Hub

Useful: 
kubectl --namespace=mdhub exec -it jupyter-jackmoore5021 -- /bin/bash
helm upgrade mdhub jupyterhub/jupyterhub --version=v0.4 -f config.yaml --timeout 1800
