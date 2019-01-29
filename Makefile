.DEFAULT: all
.PHONY: all

REGISTRY?=meme-generator
IMAGE_TAG?=latest
CACHE_IMAGE_TAG?=latest
PROMO_IMAGE_TAG?=latest

all: build/php build/php-dev build/source test/source build/app

pull/%:
	docker pull $(REGISTRY)/$*:$(IMAGE_TAG) | true

build/php:
	docker build \
		-t $(REGISTRY)/php:$(IMAGE_TAG) \
		--target php \
		${PWD}

build/php-dev:
	docker build \
		-t $(REGISTRY)/php-dev:$(IMAGE_TAG) \
		--target source \
		--cache-from $(REGISTRY)/php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/php-dev:latest \
		${PWD}

build/source:
	docker build \
		-t $(REGISTRY)/source:$(IMAGE_TAG) \
		--target source \
		--cache-from $(REGISTRY)/php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/php-dev:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/source:latest \
		${PWD}

build/app:
	docker build \
		-t $(REGISTRY)/app:$(IMAGE_TAG) \
		--target app \
		--cache-from $(REGISTRY)/php:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/php-dev:$(CACHE_IMAGE_TAG)\
		--cache-from $(REGISTRY)/source:$(CACHE_IMAGE_TAG) \
		--cache-from $(REGISTRY)/app:latest \
		${PWD}

test/source:
	docker run \
		--rm \
		-v $(PWD)/tests:/app/tests \
		$(REGISTRY)/source:$(IMAGE_TAG) \
		sh -c "composer install --dev --no-scripts --no-progress && bin/phpunit"

push/%:
	docker push $(REGISTRY)/$*:$(IMAGE_TAG)

promote/%:
	docker tag $(REGISTRY)/$*:$(IMAGE_TAG) $(REGISTRY)/$*:$(PROMO_IMAGE_TAG)
	docker push $(REGISTRY)/$*:$(IMAGE_TAG)

release/%:
	docker tag $(REGISTRY)/$*:$(IMAGE_TAG) $(REGISTRY)/$*:latest
	docker push $(REGISTRY)/$*:$(IMAGE_TAG)
	docker push $(REGISTRY)/$*:latest
