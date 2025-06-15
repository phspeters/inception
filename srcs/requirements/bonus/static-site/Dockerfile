FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    nginx && \
    rm -rf /var/cache/apk/*

RUN rm -rf /var/www/localhost/htdocs/*

COPY ./tools/index.html /var/www/localhost/htdocs

COPY ./conf/default.conf /etc/nginx/http.d/default.conf

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]