## Images

The helm chart uses two custom docker images defined in the images folder.
### hub
The hub is a modification of jupyterhub's k8s-hub image.  The container runs the jupyterhub command, serves as the hub itself, then uses jupyterhub's [kubespawner](https://github.com/jupyterhub/kubespawner) module to spawn each user's notebooks inside the same cluster.  You can also modify the layout of the notebook by modifying custom.css, and you can add a custom.js file to modify the javascript, both located in the notebook python package.
### notebook
The notebook image is the notebook to be spawned by the hub.  In this case it's a notebook built on top of model deploy, with some added features.  Model deploy copies a group of starter notebooks to the $HOME/work directory, but the hub uses a persistent volume container to store data that is mounted on top of that directory, so the notebooks must be added after the volume has been mounted, which is taken care of in post_start.sh.  Post_start.sh and pre_stop.sh are lifecycle hooks that also create and shut down a user dedicated engine on the cluster, along with update the fastscore config file.