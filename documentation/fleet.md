## Fastscore Fleet

Model Deploy Hub takes advantage of [Fastscore](http://docs.opendatagroup.com/docs/getting-started-with-fastscore)'s ability to be deployed on a kubernetes cluster.  To deploy a fleet use the commands:
```shell
kubectl --namespace=[NAMESPACE] create -f ./images/fastscore.yaml
kubectl --namespace=[NAMESPACE] create -f ./images/kafka.yaml
```
Then configurate the fleet using the restart_config script in the hub container
```shell
kubectl --namespace=[NAMESPACE] exec [HUB_POD_NAME] -- [bash /serviceaccount/restart_config.sh]
```
This will set up a fastscore fleet with 0 engines, and engines will automatically be spawned with each new jupyter notebook created.