FROM php:7.4-fpm

RUN apt-get update -y \
    && apt-get install -y nginx

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    unzip
    
RUN docker-php-ext-install zip

COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh

RUN apt-get install -y --no-install-recommends git zip
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --chown=www-data:www-data . /var/www/mysite

RUN cd /var/www/mysite && \
    composer install

WORKDIR /var/www/mysite

EXPOSE 80 443

ENTRYPOINT ["sh", "/etc/entrypoint.sh"]
