FROM alpine:3.21

# Install PHP 8.2, PHP-FPM, and other extensions
RUN	apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \
	php82-json \
	php82-curl \
	php82-xml \
	php82-mbstring \
	php82-zip \
	php82-gd \
	php82-phar \
	php82-redis \
	mariadb-client \
	curl \
	su-exec

# Create symlink (shortcut) so 'php' command works
RUN ln -s /usr/bin/php82 /usr/bin/php

# Install WP-CLI
RUN	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM pool config
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Create PHP run directory
RUN mkdir -p /run/php && chmod 755 /run/php

# Copy and set permissions for the entrypoint script
COPY tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/start.sh"]
