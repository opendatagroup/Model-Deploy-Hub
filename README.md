# Model Deploy Hub

Model-Deploy-Hub is an implementation of Jupyterhub on a kubernetes cluster using the fastscore model deploy notebook.  This allows data scientists to write models, run said models, and include comments in their notebooks, all the while including the Fastscore library and engines.

![alt text](https://github.com/jackmoore5021/Model-Deploy-Hub/blob/master/documentation/Model_Deploy_Hub_Diagram.jpg "Model Deploy Hub Diagram")

## Requirements<a name=#requirements></a>
- Kubernetes: [Install](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Helm: [Install](https://github.com/kubernetes/helm)
- Jupyterhub: [Install](https://github.com/jupyterhub/jupyterhub)
- Fastscore: [Install](http://docs.opendatagroup.com/docs/getting-started-with-fastscore#installing-fastscore)
## Example Deployment on Google Cloud Platform<a name="example"></a>
### Create a google cloud container
Make sure you have the [gcloud SDK](https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version) and it's configured to your account.
First install kubectl
```shell
gcloud components install kubectl
```
Next create a cluster
```shell
gcloud container clusters create [NAMESPACE] --num-nodes=3 --machine-type=n1-standard-1 --zone=us-central1-a
```
Take note of the MASTER_IP that's outputted from this, then replace the MASTER_IP brackets with its value in the config.yaml file.

### Authorization
This demo uses GitHub OAuth to authenticate users.  In order to set this up, go to their [developer settings](https://github.com/settings/developers) and register a new application.  Remember the ID and Secret, then copy them into the auth value in config.yaml, along with MASTER_IP if you haven't done so already.

### Helm
Initialize helm by running
```shell
helm init
```
Generate two cookie secrets using
```shell
openssl rand -hex 32
```
and put them in the config.yaml hub.cookieSecret and proxy.secretToken values
You'll need to add the jupyterhub helm chart by running
```shell
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
```
 
Now deploy the kubernetes cluster by running
```shell
helm install jupyterhub/jupyterub --version=0.4 --name=[HELM_IDENTIFIER] --namespace=[NAMESPACE] -f config.yaml --timeout 1800
```
It should take a while to download the first time you run this, but when you're finished run the following command to see the hub and proxy deployed
```shell
kubectl --namespace=[NAMESPACE] get po
```
### Setting up fastscore fleet
Next you're going to want to deploy the fastscore fleet.  This is done by running the command:
```shell
kubectl --namespace=[NAMESPACE] create -f ./fleet/fastscore.yaml
kubectl --namespace=[NAMESPACE] create -f ./fleet/kafka.yaml
```
Then configurate the fleet using the restart_config script in the hub container
```shell
kubectl --namespace=[NAMESPACE] exec [HUB_POD_NAME] -- [bash /serviceaccount/restart_config.sh]
```
You now have a running fastscore fleet on the same cluster as your jupyterhub, and the engines are fully managed by the notebook containers.


