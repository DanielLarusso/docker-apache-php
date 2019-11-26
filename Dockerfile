# pull from default image
FROM php:7.3-apache

ENV WORKDIR /var/www/html

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --fix-missing apt-utils && \
    apt-get install -y wget

RUN apt-get update -y && apt-get install -y \
    libssh2-1-dev \
    libssh2-1 \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libxml2-dev \
    libicu-dev \
    libmcrypt-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    libcurl3 \
    libxslt1-dev \
    zlib1g-dev \
    curl \
    vim \
    git \
    zip \
    unzip

# install php extensions
RUN docker-php-ext-install \
    gd \
    zip \
    curl \
    intl \
    pdo \
    pdo_mysql \
    soap

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    pecl install ssh2-1.1.2

RUN a2enmod rewrite
RUN a2enmod ssl

# create nifty ls -al alias
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer --version=1.9.1
RUN php -r "unlink('composer-setup.php');"

# set ownership of /var/www
RUN chown -R 1000:www-data /var/www

# apache2 setup
COPY ./config/vhost.conf /etc/apache2/sites-available/000-default.conf

WORKDIR $WORKDIR

EXPOSE 80
