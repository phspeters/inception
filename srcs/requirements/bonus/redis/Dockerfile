FROM alpine:3.21

RUN apk update && \
        apk add --no-cache redis && \
        # Update Redis configuration
        sed -i \
                -e "s|^bind 127.0.0.1.*|#bind 127.0.0.1|" \
                -e "s|^# maxmemory <bytes>|maxmemory 64mb|" \
                -e "s|^protected-mode yes|protected-mode no|" \
                /etc/redis.conf && \
        echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf && \

EXPOSE 6379

# Start Redis using the configuration file
ENTRYPOINT ["redis-server"]
CMD ["/etc/redis.conf"]