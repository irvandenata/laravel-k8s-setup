FROM php:8.2-fpm AS base
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    libzip-dev \
    curl \
    bash \
    libpq-dev \
    libonig-dev
RUN docker-php-ext-install exif
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo_mysql

FROM base AS dev

COPY /composer.json composer.json
COPY /composer.lock composer.lock
COPY /app app
COPY /bootstrap bootstrap
COPY /config config
COPY /artisan artisan

FROM base AS build-fpm

WORKDIR /var/www/html

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY /artisan artisan
COPY . /var/www/html
# COPY /composer.json composer.json
# RUN composer dump-autoload -o
# RUN composer clearcache
# RUN composer dump-autoload
RUN composer update --no-interaction --no-dev --no-scripts
RUN chmod +x artisan
RUN chmod o+w storage/ -R
COPY /bootstrap bootstrap
COPY /app app
COPY /config config
COPY /routes routes

# COPY . /var/www/html


FROM build-fpm AS fpm

COPY --from=build-fpm /var/www/html /var/www/html
