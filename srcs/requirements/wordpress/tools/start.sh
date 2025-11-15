#!/bin/sh
# shebang -> if no shell -> exit on error
sleep 5
set -e

# Wait for MariaDB to be ready
 until mariadb-admin ping -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do 
 	echo "Waiting for MariaDB..."
 	sleep 2
done

# If WordPress is not installed install it
if [ ! -f ./wp-config.php ]; then
	echo "Downloading WordPress..."
	wp core download --allow-root

	echo "Configuring wp-config.php..."
	wp config create \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$MYSQL_HOSTNAME" \
		--allow-root

	echo "Installing WordPress..."
	wp core install \
		--url="$DOMAIN_NAME" \
		--title="$WORDPRESS_TITLE" \
		--admin_user="$WORDPRESS_ADMIN" \
		--admin_password="$WORDPRESS_ADMIN_PASS" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL" \
		--skip-email \
		--allow-root
	
	# Create a second user as author -> no management capacity
	wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
		--role=author \
		--user_pass="$WORDPRESS_USER_PASS" \
		--allow-root
	
	# Install and activate a theme for the website
	wp theme install qi --activate --allow-root
fi

echo "Starting PHP-FPM..."
#using --nodaemonize flag to keep the process attached to the terminal (PID1)
exec php-fpm82 --nodaemonize
