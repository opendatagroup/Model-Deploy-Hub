VERSION=v0.1
IMAGE_PREFIX=jackmoore/mdchart

images: build-images push-images
build-images: build-image/hub
push-images: push-image/hub

build-image/%:
	cd images/$(@F) && \
	docker build -t $(IMAGE_PREFIX)$(@F):$(VERSION) .

push-image/%:
	docker push $(IMAGE_PREFIX)$(@F):$(VERSION)

package-chart:
	helm package jupyterhub
