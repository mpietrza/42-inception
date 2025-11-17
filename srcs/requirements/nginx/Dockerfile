FROM alpine:3.21

RUN	apk add --no-cache nginx openssl curl

RUN mkdir -p /var/www /var/www/html /etc/nginx/ssl

# generate a self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=ES/ST=Catalunya/L=Barcelona/O=42/OU=42/CN=${DOMAIN_NAME}"

COPY tools/nginx_start.sh /var/www/
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/mime.types /etc/nginx/mime.types

# make the start script executable and set permissions for the web directory
RUN chmod +x /var/www/nginx_start.sh && chmod 755 /var/www/html

EXPOSE 443

ENTRYPOINT [ "/var/www/nginx_start.sh" ]

CMD ["nginx", "-g", "daemon off;"]
