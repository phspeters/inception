FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    redis && \
    rm -rf /var/cache/apk/*

RUN sed -i \
        -e "s|^bind 127.0.0.1.*|#bind 127.0.0.1|" \
        -e "s|^# maxmemory <bytes>|maxmemory 64mb|" \
        -e "s|^protected-mode yes|protected-mode no|" \
        /etc/redis.conf && \
    echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf

EXPOSE 6379

ENTRYPOINT ["redis-server"]

CMD ["/etc/redis.conf"]