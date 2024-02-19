FROM mysql:5.7

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=sample
ENV MYSQL_USER=sample
ENV MYSQL_PASSWORD=sample

COPY database.sql /docker-entrypoint-initdb.d/00-database.sql
