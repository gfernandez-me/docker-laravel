# Build Stage 1
# FROM composer:1.9 AS composer
# WORKDIR /var/www/api
# COPY . /var/www/api
# RUN composer install --ignore-platform-reqs --no-interaction --no-dev --prefer-dist --optimize-autoloader

# Build Stage 3
FROM php:7.4-apache
ENV ACCEPT_EULA=Y

# Install system dependencies
RUN apt-get install -y apt-utils
RUN apt-get update && apt-get install -y \
    rsync \
    git \
    curl \
    libmemcached-dev \
    libpq-dev  \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libxml2-dev \
    gnupg \
    apt-transport-https

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install zip xml mbstring exif pcntl bcmath gd bcmath sockets pcntl

# PHP INI
COPY 00_php.ini /etc/php7.4/conf.d

# Apache configuration
COPY apache.conf /etc/apache2/conf.d

###########################################################################
# PHP MSSQL:
###########################################################################
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv \
    && echo "extension=pdo_sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini \
    && echo "extension=sqlsrv.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -g www-data ubuntu
RUN mkdir -p /home/ubuntu/.composer && \
    chown -R ubuntu:www-data /home/ubuntu

# Set working directory
WORKDIR /var/www

USER ubuntu