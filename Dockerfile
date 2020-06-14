FROM php:7-fpm-alpine3.12

ARG PHPCONF=/usr/local/etc/php/conf.d

ENV EUID 11000
ENV EGID 21000

RUN \
    build_pkgs="build-base autoconf automake libmemcached-dev imagemagick-dev wget libtool libzip-dev zlib-dev libedit-dev cyrus-sasl-dev readline-dev libxml2-dev gd-dev curl-dev gmp-dev libpng-dev freetype-dev zlib-dev libxpm-dev libwebp-dev" \
    && runtime_pkgs="libmemcached libgcc imagemagick libltdl readline libxml2 gd curl gmp libzip libpng libedit libjpeg freetype zlib libxpm libwebp libstdc++" \
    && apk --no-cache add ${build_pkgs} ${runtime_pkgs} ca-certificates \
    && update-ca-certificates

RUN docker-php-ext-install xmlrpc curl gd gmp json mysqli pdo pdo_mysql exif zip
RUN docker-php-ext-enable json mysqli pdo pdo_mysql opcache exif zip

ADD https://github.com/php-memcached-dev/php-memcached/archive/v3.1.5.zip /tmp/memcache/ 
RUN cd /tmp/memcache \
    && unzip v3.1.5.zip \
    && cd php-memcached-3.1.5 \
    && phpize \
    && ./configure \
    && make && make install \
    && cd / \
    && rm -rf /tmp/memcache \
    && docker-php-ext-enable memcached

ADD https://pecl.php.net/get/imagick-3.4.4.tgz /tmp/imagick/
RUN cd /tmp/imagick \
    && tar -zxf imagick-3.4.4.tgz \
    && cd imagick-3.4.4 \
    && phpize \
    && ./configure \
    && make && make install \
    && cd / \
    && rm -rf /tmp/imagick \
    && docker-php-ext-enable imagick

RUN apk --no-cache del ${build_pkgs}
RUN apk --no-cache add ${runtime_pkgs}

CMD ["php-fpm", "-F", "-O"]
