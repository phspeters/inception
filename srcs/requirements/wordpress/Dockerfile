FROM alpine:3.21

ARG WWW_DATA_UID=82

RUN adduser -u ${WWW_DATA_UID} -S www-data -G www-data -h /var/www/html -s /sbin/nologin

RUN apk update && apk upgrade && apk add --no-cache \
    bash \
    curl \
    mariadb-client \
    openssl \
    icu-data-full \
    php82 \
    php82-fpm \
    php82-phar \
    php82-json \
    php82-mysqli \
    php82-curl \
    php82-dom \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-simplexml \
    php82-xmlreader \
    php82-zip \
    php82-gd \
    php82-fileinfo \
    php82-exif \
    php82-intl \
    php82-tokenizer \
    php82-sodium \
    php82-zlib && \
    ln -s /usr/bin/php82 /usr/bin/php && \
    rm -rf /var/cache/apk/*

RUN sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php82/php.ini

RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]