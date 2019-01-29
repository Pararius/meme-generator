FROM php:7.3.1-fpm-alpine AS php

RUN apk add --no-cache --virtual .build-deps autoconf g++ make \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    && apk del .build-deps

RUN apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

WORKDIR /app

FROM php AS php-dev

ENV COMPOSER_MEMORY_LIMIT -1
ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer:1.7.2 /usr/bin/composer /usr/bin/composer

RUN composer global require hirak/prestissimo \
    && composer clear-cache

FROM php-dev AS source

COPY composer.json composer.lock /app/

RUN composer install --no-scripts --no-autoloader --no-dev \
    && composer clear-cache

COPY . /app/

ARG APP_ENV=prod
ENV APP_ENV=${APP_ENV}

RUN composer dump-autoload --optimize --no-dev \
    && composer run-script post-install-cmd

FROM php AS app

COPY --from=source /app/ /app/
