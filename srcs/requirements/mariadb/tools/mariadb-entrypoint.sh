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
	echo "First run, initializing MariaDB configuration..."
	cat <<-EOF >/etc/my.cnf.d/mariadb-server.cnf
	[mysqld]
	bind-address=0.0.0.0
	skip-networking=0
EOF

	# Create the .firstrun file to indicate that initialization has been done
	touch /etc/.firstrun
	echo "MariaDB configuration initialized."
else
	echo "MariaDB configuration already initialized."
fi

# If it's the first time mounting the data volume, initialize the database
if [ ! -e /var/lib/mysql/.firstmount ]; then
	echo "First run, initializing MariaDB database..."
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
	--auth-root-authentication-method=socket >/dev/null 2>&1

	# Start the MariaDB server in the background
	mysqld_safe --datadir=/var/lib/mysql &

	# Wait for the server to start
	mysqladmin ping -u root --silent --wait >/dev/null 2>&1

	# Set up the root user and create a test database
	mysql --protocol=socket -u root -p= <<-EOF
	CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
	
	CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
	GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
	
	CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
	
	FLUSH PRIVILEGES;
EOF

	# Shut down the temporary server and mark the volume as initialized
	mysqladmin shutdown
	touch /var/lib/mysql/.firstmount
	echo "MariaDB database initialized."
else
	echo "MariaDB database already initialized."
fi

# Start the MariaDB server in the foreground
exec mysqld_safe --datadir=/var/lib/mysql --user=mysql --group=mysql \
	--auth-root-authentication-method=socket