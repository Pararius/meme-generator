.DEFAULT: all
.PHONY: all build/php build/app

REGISTRY?=meme-generator
IMAGE_TAG?=latest

all: build/app

build/php:
	docker build \
		-t $(REGISTRY)/php:$(IMAGE_TAG) \
		docker/php

build/app: build/php
	docker build \
		-t $(REGISTRY)/app:$(IMAGE_TAG) \
		--build-arg BASE_IMAGE=$(REGISTRY)/php \
		${PWD}
