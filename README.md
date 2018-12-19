Meme Generator
---

This repository complements the Docker workshop given for REC employees.

# Prerequisites

We assume you have the following prerequisites met:

- A local Docker installation
- A working Docker Compose installation

# Setting up your services

To get this app up and running, you will need to define the following services inside a `docker-compose.yml` file.

- [composer](https://hub.docker.com/_/composer/) - Makes sure all project dependencies are installed using Composer
- [nginx](https://hub.docker.com/_/nginx/) - Will handle all HTTP requests to your application
- [php](https://hub.docker.com/_/php/) - Will serve as an nginx backend for PHP files
- [redis](https://hub.docker.com/_/redis/) - Will cache all the data generated by our end users

# Setup hints

## composer

- The official Composer image uses the Composer binary as it's entrypoint.
All you got to do is pass the `command` you want to run upon spinning up the container.
- The expected command is `install`, so `composer install` will be run. The `composer` part is the entrypoint of this
image, so you don't need to supply that.
- Composer expects to find your composer.json and composer.lock files in the `/app` folder inside the container.

## nginx

- You will need to mount your vhost configuration as `/etc/nginx/conf.d/vhost.conf`
- You will need to forward any local port to port 80 in the container
- The webroot for your application is `/app`. Make sure to add a mount to your project source code using [volumes](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)

## php

- Start with the base FPM image for now (`php:7.2-fpm`)
- We will need to customize it in our next step (await instructions)

# Extending images

## php

For examples, see the official Docker Hub page for the PHP images: https://hub.docker.com/_/php/

Make a Dockerfile that extends the FPM image by installing the required extensions in a new custom image.
Don't forget to add a `build` attribute to your service in your `docker-compose.yml` file.

# Optimizing images

When you have a working PHP image, it's still pretty large (~400MB).
Most images also support an "Alpine" version. This is a version of the image based on Alpine Linux.
Alpine Linux is famous for being (one of) the smallest Linux distributions.
Get a working PHP installation based on the `php:7.2-fpm-alpine` image.

