FROM php:7-apache
EXPOSE 80
WORKDIR /var/www/html
COPY . /var/www/html

RUN chmod a+x .shipped/build  .shipped/test

RUN [".shipped/build"]

