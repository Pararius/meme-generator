#!/bin/bash

export REGISTRY=localhost:5000/meme-generator

set -euox pipefail

##
## Build
##
make pull/php pull/php-dev
IMAGE_TAG=pr-101 CACHE_IMAGE_TAG=pr-101 make build/php build/php-dev
IMAGE_TAG=pr-101 make push/php push/php-dev

##
## Test
##
IMAGE_TAG=pr-101 make pull/php pull/php-dev
make pull/source
IMAGE_TAG=pr-101 CACHE_IMAGE_TAG=pr-101 make build/source
IMAGE_TAG=pr-101 make test/source
make push/source

##
## Build prod
##
IMAGE_TAG=pr-101 make pull/php pull/php-dev pull/source
IMAGE_TAG=pr-101 CACHE_IMAGE_TAG=pr-101 make build/app

##
## Release
##
export PROMO_IMAGE_TAG=51e6e275
exportk IMAGE_TAG=pr-101
make promote/php promote/php-dev promote/source promote/app
IMAGE_TAG=$PROMO_IMAGE_TAG make release/php release/php-dev release/source release/app
