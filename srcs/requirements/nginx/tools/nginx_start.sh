#!/bin/sh

# generating SSL cert if for some reason it doesn't exist
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=ES/ST=Catalunya/L=Barcelona/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"
