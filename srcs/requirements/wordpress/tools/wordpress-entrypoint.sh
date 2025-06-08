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
	echo "First run, updating PHP-FPM configuration ..."
	sed -i "s/listen = 127.0.0.1:9000/listen = 9000/g" /etc/php82/php-fpm.d/www.conf
	touch /etc/.firstrun
	echo "PHP-FPM configuration updated."
else
	echo "PHP-FPM configuration already initialized."
fi

# If it's the first time mounting the data volume, initialize the WordPress configuration
if [ ! -e /etc/.firstmount ]; then
	echo "First run, initializing WordPress configuration ..."
	# Wait for the MariaDB server to be ready
	mariadb-admin ping --protocol=tcp -h mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1

	if [ ! -f /var/www/html/wp-config.php ]; then
		echo "Installing WordPress ..."
		if [ ! -f /var/www/html/wp-includes/version.php ]; then
			wp core download --allow-root;
		fi
		wp config create --allow-root --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="mariadb"
		wp config set WP_REDIS_HOST redis --allow-root
		wp config set WP_REDIS_PORT 6379 --raw --allow-root
		wp config set WP_CACHE true --raw --allow-root
		wp config set FS_METHOD direct --raw --allow-root
		wp core install --allow-root --url="$DOMAIN_NAME" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL"
		we plugin install redis-cache --activate --allow-root

		if ! wp user get "$WORDPRESS_USER" --allow-root >/dev/null 2>&1; then
			echo "Creating wordpress user ..."
			wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=administrator --user_pass="$WORDPRESS_PASSWORD" --allow-root
		fi
	fi

	# Not recommended for production as it allows anyone to write to the wp-content directory
	chmod o+w -R /var/www/html/wp-content
	touch /etc/.firstmount
	echo "WordPress configuration initialized."
else
	echo "WordPress configuration already initialized."
fi

# Start the PHP-FPM service
exec /usr/sbin/php-fpm82 --nodaemonize --fpm-config /etc/php82/php-fpm.conf