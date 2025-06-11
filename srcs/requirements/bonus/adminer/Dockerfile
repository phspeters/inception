FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    php82 \
    php82-session \
    php82-mysqli \
    wget

WORKDIR /var/www

RUN wget https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php && \
    mv adminer-5.3.0.php index.php && \
    chown -R root:root /var/www/

EXPOSE 8080

ENTRYPOINT [ "php82" ]

CMD [ "-S", "[::]:8080", "-t", "/var/www" ]