FROM alpine:3.21

RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

WORKDIR /app

RUN curl -L https://github.com/portainer/portainer/releases/download/2.30.1/portainer-2.30.1-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar xzf portainer.tar.gz \
    && rm portainer.tar.gz

EXPOSE 9000

ENTRYPOINT ["/app/portainer/portainer"]