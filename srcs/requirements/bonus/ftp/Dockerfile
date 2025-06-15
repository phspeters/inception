FROM alpine:3.21

ARG WWW_DATA_UID=82

RUN adduser -u ${WWW_DATA_UID} -S www-data -G www-data -h /var/www/html -s /sbin/nologin

RUN apk update && apk upgrade && apk add --no-cache \
    vsftpd \
    shadow && \
    rm -rf /var/cache/apk/*

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
    
COPY tools/ftp-entrypoint.sh /usr/local/bin/ftp-entrypoint.sh

RUN chmod +x /usr/local/bin/ftp-entrypoint.sh

EXPOSE 20 21 21100-21110

ENTRYPOINT ["ftp-entrypoint.sh"]