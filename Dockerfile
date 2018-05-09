FROM php:7.2.2-apache

RUN apt-get update && \
    apt-get install -y freetds-dev wget git 

RUN apt-get install apt-transport-https -y

#install sql server ODBC Driver
RUN apt-get update && apt-get install -my wget gnupg
RUN curl -S https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl -S https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/ && \
    docker-php-ext-install pdo_dblib
# optional: for unixODBC development headers
RUN apt-get install unixodbc-dev -y



ADD composer-setup.sh /
RUN chmod +x /composer-setup.sh && \
    /composer-setup.sh

RUN apt-get install nano -y

RUN pecl install sqlsrv pdo_sqlsrv
RUN echo "extension= pdo_sqlsrv.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`
RUN echo "extension= sqlsrv.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 -y


RUN mkdir /var/www/files && chown -R www-data:www-data /var/www/files
COPY dashboardrrg/ /var/www/html/
COPY config/php.ini /usr/local/etc/php
COPY config/php.ini /usr/local/lib/php 
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

COPY php.ini /usr/local/lib

WORKDIR /var/www/html
