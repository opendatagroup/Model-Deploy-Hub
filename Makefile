NAMESPACE=mdhdemo
DOCKERUSER=jackmoore
DOCKERHUBIMAGE=hub
DOCKERNBIMAGE=notebook
$(eval PUBLICIP:=$(shell kubectl --namespace=$(NAMESPACE) get svc | grep "proxy-public" | awk '{print $$3}'))

# Package chart, serve on local machine, and add to repo
chart:


# Build, push docker images and update config.yaml
images: hub notebook
hub:
	@$(eval NEWTAG:=$(shell openssl rand -hex 16))
	@docker build -q -t $(DOCKERUSER)/$(DOCKERHUBIMAGE):$(NEWTAG) $$(pwd)/images/$(DOCKERHUBIMAGE)/.
	@docker push $(DOCKERUSER)/$(DOCKERHUBIMAGE):$(NEWTAG)
	@awk 'f{$$0="        tag: $(NEWTAG)";f=0}/$(DOCKERUSER)\/$(DOCKERHUBIMAGE)/{f=1}1' config.yaml > config.tmp && mv config.tmp config.yaml
notebook:
	@$(eval NEWTAG:=$(shell openssl rand -hex 16))
	@docker build -q -t $(DOCKERUSER)/$(DOCKERNBIMAGE):$(NEWTAG) $$(pwd)/images/$(DOCKERNBIMAGE)/.
	@docker push $(DOCKERUSER)/$(DOCKERNBIMAGE):$(NEWTAG)
	@awk 'f{$$0="        tag: $(NEWTAG)";f=0}/$(DOCKERUSER)\/$(DOCKERNBIMAGE)/{f=1}1' config.yaml > config.tmp && mv config.tmp config.yaml

# Open website
open:
	@/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito --disable-gpu "$(PUBLICIP)"

# Upgrade after new config.yaml settings or new docker images
upgrade:
	@mkdir temp_chart_directory
	@helm package ./chart/jupyterhub
	@mv jupyterhub-v0.4.tgz temp_chart_directory
	@helm repo index ./temp_chart_directory/
	@helm serve --repo-path ./temp_chart_directory/ &
	@sleep 5
	@helm repo add jupyterhub http://127.0.0.1:8879
	@helm upgrade $(NAMESPACE) jupyterhub/jupyterhub --version=v0.4 -f config.yaml --timeout=3600 --wait
	@kill $$(ps aux | grep "[h]elm serve --repo-path" | awk '{print $$2}')
	@rm -r ./temp_chart_directory
# Open a shell in a pod
exec:
	@$(eval POD:=$(shell bash -c 'read -p "Enter pod you want to run a shell in: " pod; echo $$pod'))
	@$(eval PODNAME:=$(shell kubectl --namespace=$(NAMESPACE) get pods | grep "${POD}" | awk '{print $$1}'))
	@kubectl --namespace=$(NAMESPACE) exec -it $(PODNAME) -- /bin/bash
test:
	@# Test output of various commands






