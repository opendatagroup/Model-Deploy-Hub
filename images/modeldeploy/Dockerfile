FROM fastscore/model-deploy:latest

USER $NB_USER
WORKDIR $HOME
# Add sample notebooks to .starterNotebooks directory
RUN mkdir .starterNotebooks
COPY Python2_Example_Usage.ipynb /$HOME/.starterNotebooks
COPY Python3_Example_Usage.ipynb /$HOME/.starterNotebooks
COPY R_Example_Usage.ipynb /$HOME/.starterNotebooks
COPY PFA_Example_Usage.ipynb /$HOME/.starterNotebooks
# Add engine maintainers
COPY pre_stop.sh /$HOME
COPY post_start.sh /$HOME
COPY engine_deploy_empty.json /$HOME
COPY engine_svc_empty.json /$HOME
COPY empty_config.json /$HOME
# Change ownership of $HOME so NB_USER can run the lifecycle scripts to maintain engines
USER root
RUN chown -R $NB_USER:users /$HOME/.
# Change back to NB_USER and change working directory to the location of the user's PVC
USER $NB_USER
WORKDIR /home/jovyan/work