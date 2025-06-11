FROM alpine:3.21

RUN apk update && \
    apk upgrade && \
    apk add --no-cache nginx openssl bash && \
    rm -rf /var/cache/apk/*

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
    mkdir -p /etc/nginx/ssl

ENTRYPOINT ["nginx-entrypoint.sh"]