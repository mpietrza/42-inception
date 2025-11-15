FROM alpine:3.21

RUN	apk add --no-cache mariadb mariadb-client 

COPY conf/mariadb.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/mariadb.sh /usr/local/bin/mariadb.sh

RUN	chmod +x /usr/local/bin/mariadb.sh
RUN	mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && chmod 755 /run/mysqld

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
