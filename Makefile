.DEFAULT: all
.PHONY: all

REGISTRY=treehouselabs
IMAGE_PREFIX=meme-generator
IMAGE_TAG?=latest
CACHE_IMAGE_TAG?=latest
PROMO_IMAGE_TAG?=latest
DOCKER_USERNAME?=
DOCKER_PASSWORD?=

all: build/php build/php-dev build/source test/source build/app

pull/%:
	docker pull $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG)

build/php:
	docker build \
		-t $(REGISTRY)/$(IMAGE_PREFIX)-php:$(IMAGE_TAG) \
		--target php \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php:latest \
		${PWD}

build/php-dev:
	docker build \
		-t $(REGISTRY)/$(IMAGE_PREFIX)-php-dev:$(IMAGE_TAG) \
		--target php-dev \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php-dev:latest \
		${PWD}

build/source:
	docker build \
		-t $(REGISTRY)/$(IMAGE_PREFIX)-source:$(IMAGE_TAG) \
		--target source \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php-dev:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-source:latest \
		${PWD}

build/app:
	docker build \
		-t $(REGISTRY)/$(IMAGE_PREFIX)-app:$(IMAGE_TAG) \
		--target app \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-php-dev:$(CACHE_IMAGE_TAG)\
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-source:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/$(IMAGE_PREFIX)-app:latest \
		${PWD}

test/source:
	docker run \
		--rm \
		-v $(PWD)/tests:/app/tests \
		$(REGISTRY)/$(IMAGE_PREFIX)-source:$(IMAGE_TAG) \
		sh -c "composer install --dev --no-scripts --no-progress && bin/phpunit"

push/%:
	docker push $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG)

promote/%:
	docker tag $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG) \
		$(REGISTRY)/$(IMAGE_PREFIX)-$*:$(PROMO_IMAGE_TAG)
	docker push $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG)

release/%:
	docker tag $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG) \
		$(REGISTRY)/$(IMAGE_PREFIX)-$*:latest
	docker push $(REGISTRY)/$(IMAGE_PREFIX)-$*:$(IMAGE_TAG)
	docker push $(REGISTRY)/$(IMAGE_PREFIX)-$*:latest

login:
	echo $(DOCKER_PASSWORD) | docker login -u $(DOCKER_USERNAME) --password-stdin
