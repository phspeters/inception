#!/bin/bash
set -e

# Function to call on error
log_error() {
	local exit_code=$?
	local line_number=$1
	local command=$2
	echo "Error on line $line_number: command '$command' exited with status $exit_code." >&2
}

# Trap ERR signal to call log_error function
# $LINENO and $BASH_COMMAND are special bash variables
trap 'log_error $LINENO "$BASH_COMMAND"' ERR

# If it's the first time the container is started, initialize the configuration
if [ ! -e /etc/.firstrun ]; then
	echo "First run, initializing Nginx ..."

	# Generate self-signed SSL certificate and key for HTTPS
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout '/etc/nginx/ssl/nginx.key' \
		-out '/etc/nginx/ssl/nginx.crt' \
		-subj "/CN=$DOMAIN_NAME" \
		>/dev/null 2>&1
	echo "Certificate and Key generated at /etc/nginx/ssl"

	# Create nginx configuration file
	cat <<-EOF >/etc/nginx/conf.d/default.conf
	server {
		listen 443 ssl http2;
		listen [::]:443 ssl http2;
		server_name $DOMAIN_NAME;

		ssl_certificate /etc/nginx/ssl/nginx.crt;
		ssl_certificate_key /etc/nginx/ssl/nginx.key;
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

		root /var/www/html;
		index index.php index.html index.htm;

		location / {
			try_files \$uri \$uri/ /index.php?\$args;
		}

		location ~ \.php(?:/|$) {
			try_files \$fastcgi_script_name =404;

			fastcgi_split_path_info ^(.+\.php)(/.*)\$;
			fastcgi_pass wordpress:9000;
			fastcgi_index index.php;
			include fastcgi_params;
			fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
			fastcgi_param PATH_INFO \$fastcgi_path_info;
		}
	}
EOF

	# Create the .firstrun file to indicate that initialization has been done
	touch /etc/.firstrun
	echo "Nginx configuration initialized."
else
	echo "Nginx configuration already initialized."
fi

exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf	