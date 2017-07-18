VERSION=latest
IMAGE_PREFIX=jackmoore/mdchart
PUSH_IMAGES=no

images: build-images push-images
build-images: build-image/hub build-image/modeldeploy
push-images: push-image/hub push-image/modeldeploy

build-image/%:
	cd images/$(@F) && \
	docker build -t $(IMAGE_PREFIX)-$(@F)v$(VERSION) .

push-image/%:
	docker push $(IMAGE_PREFIX)-$(@F)v$(VERSION)

package-chart:
	helm package jupyterhub
