FROM phusion/baseimage:0.10.2
MAINTAINER Jake Jarvis <jake@jarv.is>
ENV REFRESHED_AT 2019-06-11

# based on mattrayner/lamp & dgraziotin/lamp
# MAINTAINER Matthew Rayner <hello@rayner.io>
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

ENV DOCKER_USER_ID 501
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

ENV PHPMYADMIN_VERSION=4.9.0.1

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/php5-compat && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install supervisor wget curl git zip unzip pwgen apache2 php5.6 libapache2-mod-php5.6 mysql-server-5.7 php5.6-mysql php5.6-mcrypt php5.6-gd php5.6-xml php5.6-mbstring php5.6-gettext php5.6-zip php5.6-curl && \
    apt-get -y autoremove && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Point PHP CLI to use 5.6
RUN ln -sfn /usr/bin/php5.6 /etc/alternatives/php

# mcrypt needed for phpMyAdmin
RUN phpenmod mcrypt

# Add image configuration and scripts
ADD config/start-apache2.sh /start-apache2.sh
ADD config/start-mysqld.sh /start-mysqld.sh
ADD config/run.sh /run.sh
RUN chmod 755 /*.sh
ADD config/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD config/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD config/mysqld_innodb.cnf /etc/mysql/conf.d/mysqld_innodb.cnf

# Allow MySQL to bind on 0.0.0.0
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
  sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Set PHP timezones to America/New_York
RUN sed -i "s/;date.timezone =/date.timezone = America\/New_York/g" /etc/php/5.6/apache2/php.ini
RUN sed -i "s/;date.timezone =/date.timezone = America\/New_York/g" /etc/php/5.6/cli/php.ini

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD config/create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

# Add phpMyAdmin
ENV PHPMYADMIN_VERSION=4.8.2
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV MYSQL_PASS:-$(pwgen -s 12 1)

# Enable .htaccess
ADD config/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Prepare /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD app/ /app

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app and MySql
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/app" ]

EXPOSE 80 3306

CMD ["/run.sh"]
