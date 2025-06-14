FROM alpine:3.21

RUN apk update && apk upgrade && apk add --no-cache \
    vsftpd \
    shadow && \
    rm -rf /var/cache/apk/*

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
    
COPY tools/ftp-entrypoint.sh /usr/local/bin/ftp-entrypoint.sh

RUN chmod +x /usr/local/bin/ftp-entrypoint.sh

EXPOSE 20 21 21100-21110

ENTRYPOINT ["ftp-entrypoint.sh"]