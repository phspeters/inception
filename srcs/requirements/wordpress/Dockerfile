FROM alpine:3.21

ARG WWW_DATA_UID=82
ARG WWW_DATA_GID=82

RUN addgroup -g ${WWW_DATA_GID} -S www-data && \
    adduser -u ${WWW_DATA_UID} -S www-data -G www-data -h /var/www/html -s /sbin/nologin

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
    php82-sodium \
    php82-zlib && \
    rm -rf /var/cache/apk/*

RUN curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]