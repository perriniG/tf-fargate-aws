FROM  php:8.1

ENV SRC_DIR /var/www/html
RUN mkdir -p $SRC_DIR

COPY ini.php $SRC_DIR
RUN  chmod -R 644 $SRC_DIR

EXPOSE 8080