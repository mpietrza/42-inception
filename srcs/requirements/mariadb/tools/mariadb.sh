#!/bin/sh
# it is a shebang -> not a comment -> specifies that script should be run with the sh shell

#Initialize MariaDB if the database directory is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB system tables..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background (needed for initial setup)
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
	echo "Waiting for MariaDB to be ready..."
	sleep 1
done

# If the database is not initialized, set it up
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Initializing database..."
		
	#Backticks (\`): for identifiers (database/table/column names) Single quotes: for string values (passwords, usernames, etc.)
	# '@'%' means that this user can connect from any host
	# .* means every table in that database
	mysql -u root <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL

		echo "Database and user created."
fi

# Shutdown the background MariaDB server
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB in the foreground (as PID 1)
exec mysqld --user=mysql --datadir=/var/lib/mysql --console

