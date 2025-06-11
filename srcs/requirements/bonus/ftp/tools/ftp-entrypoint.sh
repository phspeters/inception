#!/bin/sh
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

FTP_USER="www-data"
FTP_USER_HOME="/var/www/html"

if [ -z "$FTP_PASSWORD" ]; then
	echo "Error: FTP_PASSWORD environment variable for user $FTP_USER must be set." >&2
	exit 1
fi

# If it's the first time the container is started, initialize the configuration
if [ ! -f "/etc/vsftpd/.firstrun" ]; then
	echo "Configuring vsftpd for the first time..."
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

	mkdir -p /var/run/vsftpd/empty
	chown root:root /var/run/vsftpd

	echo "$FTP_USER" > /etc/vsftpd.userlist

	touch /etc/vsftpd/.firstrun
	echo "vsftpd configured successfully."
fi

echo "FTP started on port 21"
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf