FROM phusion/baseimage:0.10.2
MAINTAINER Jake Jarvis <jake@jarv.is>
ENV REFRESHED_AT 2019-06-11

# Based on mattrayner/lamp & dgraziotin/lamp:
# MAINTAINER Matthew Rayner <hello@rayner.io>
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

ENV DOCKER_USER_ID 501
ENV DOCKER_USER_GID 20
ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql && \
    groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/php5-compat && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
        supervisor \
        wget \
        curl \
        git \
        zip \
        unzip \
        pwgen \
        apache2 \
        mysql-server-5.7 \
        php5.6 \
        libapache2-mod-php5.6 \
        php5.6-mysql \
        php5.6-mcrypt \
        php5.6-gd \
        php5.6-xml \
        php5.6-mbstring \
        php5.6-gettext \
        php5.6-zip \
        php5.6-curl && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Point CLI to use PHP 5.6
RUN ln -sfn /usr/bin/php5.6 /etc/alternatives/php

# Add build scripts
ADD config/start-apache2.sh /start-apache2.sh
ADD config/start-mysqld.sh /start-mysqld.sh
ADD config/create_mysql_users.sh /create_mysql_users.sh
ADD config/run.sh /run.sh
RUN chmod 755 /*.sh

# Add sensible default configurations
ADD config/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD config/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD config/mysqld_innodb.cnf /etc/mysql/conf.d/mysqld_innodb.cnf
ADD config/apache_default /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Allow MySQL to bind on 0.0.0.0
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
    sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# mcrypt needed for phpMyAdmin
RUN phpenmod mcrypt

# Install phpMyAdmin
ENV PHPMYADMIN_VERSION=4.9.0.1
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz && \
    tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www && \
    ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin && \
    mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Enable mod_rewrite
RUN a2enmod rewrite

# Some more environment variables for PHP
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Set PHP timezones to America/New_York
RUN sed -i "s/;date.timezone =/date.timezone = America\/New_York/g" /etc/php/5.6/apache2/php.ini && \
    sed -i "s/;date.timezone =/date.timezone = America\/New_York/g" /etc/php/5.6/cli/php.ini

# Prepare /app folder with sample index.php
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

# Add volumes for the app and MySQL
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

# Expose Apache and MySQL
EXPOSE 80 3306

CMD ["/run.sh"]
