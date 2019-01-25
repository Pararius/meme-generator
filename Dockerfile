ARG BASE_IMAGE=meme-generator/php
FROM ${BASE_IMAGE}

COPY composer.json composer.lock /app/

RUN composer install --no-scripts --no-autoloader --no-dev

COPY . /app/

RUN composer dump-autoload --optimize --no-dev \
    && composer run-script post-install-cmd
