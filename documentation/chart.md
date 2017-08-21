## Helm Chart

Helm is used to manage the jupyterhub kubernetes cluster.  We'll use a helm package called a helm chart, and this chart consists of three components:
- templates: folders containing yaml files describing kubernetes objects
- values.yaml: default values for various variables in the templates
- config.yaml: a config file to change the variables described in values

An example is the deployment that spawns the hub container.  In the deployment.yaml file, you would find the descriptor for the container in the form:
```yaml
spec:
  template:
    spec:
      containers:
        - name: hub-container
          image: {{ .Values.hub.image.name }}:{{ .Values.hub.image.tag }}
```
This image value must be defined in the values.yaml file, which currently defaults to:
```yaml
hub:
  image:
    name: jupyterhub/k8s-hub
    tag: v0.4
```
Next, if you want to change the image which the deployment uses, you alter the .Values.hub.image.name value in config.yaml, like so:
```yaml
hub:
  image:
    name: user/customimage
    tag: latest
```

This allows you to alter many aspects of the jupyterhub kubernetes cluster by just editing the config.yaml file client side, then uploading those changes to the server using the helm command:
```shell
helm upgrade [cluster namespace] [template repo] --version=v0.4 -f config.yaml
```