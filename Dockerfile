FROM php:5.4-apache
COPY ./000-default.conf /etc/apache2/sites-enabled/

RUN a2enmod rewrite && apt-get update && apt-get install -y libmysqlclient-dev \
      libmemcached-dev \
      libxml2-dev \
      libxslt1-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng12-dev \
      libaio1 \
      libaio-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install apcu-4.0.11 \
    && docker-php-ext-enable apcu \
    && pecl install memcached-2.2.0 \
    && docker-php-ext-enable memcached \
    && pecl install memcache-2.2.7 \
    && docker-php-ext-enable memcache \
    && docker-php-ext-install mysql \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install soap \
    && docker-php-ext-install xsl \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd mbstring pdo pdo_mysql zip


RUN apt-get update && apt-get install -y unzip && apt-get install -y nano

# Oracle instantclient
ADD instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/
ADD instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/
ADD instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient_12_1"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.0.10
RUN echo "extension=oci8.so" > /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini

RUN echo "date.timezone=Europe/Madrid" >> /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini  
