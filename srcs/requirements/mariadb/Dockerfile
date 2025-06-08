FROM alpine:3.21

RUN apk update && \
	apk add --no-cache mariadb mariadb-client bash

COPY tools/mariadb-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["mariadb-entrypoint.sh"]