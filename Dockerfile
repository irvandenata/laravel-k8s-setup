FROM php:8.2-fpm
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
    # && docker-php-ext-configure mysql -with-mysql=/usr/local/mysql \
    # && docker-php-ext-install pdo pdo_mysql
RUN apt install nginx supervisor -y


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
# RUN docker-php-ext-configure gd --with-jpeg-=/usr/include/ --with-freetype=/usr/include/
RUN docker-php-ext-install gd
# Disable for development purposes

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1005 www
RUN useradd -u 1005 -ms /bin/bash -g www www
RUN mkdir -p /var/log/php-fpm/

COPY / /var/www/html
# Set working directory
WORKDIR /var/www/html
RUN /usr/local/bin/composer install

RUN chown -R www:www /var/www/html
RUN chmod -R 777 /var/www/html/storage
RUN chmod -R 777 /var/www/html/bootstrap/cache
# Copy existing application directory contents

COPY /docker/setup/nginx/default /etc/nginx/sites-enabled/default
COPY /docker/setup/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
CMD [ "/usr/bin/supervisord" ]
