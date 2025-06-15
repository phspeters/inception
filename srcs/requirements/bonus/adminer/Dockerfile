FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    php82-session \
    php82-mysqli \
    php82-curl \
    wget

WORKDIR /var/www/html

RUN wget http://www.adminer.org/latest.php -O /var/www/html/index.php

EXPOSE 8080

ENTRYPOINT [ "php82" ]

CMD [ "-S", "[::]:8080", "-t", "/var/www/html" ]