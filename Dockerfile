FROM php:7.1-fpm-alpine
MAINTAINER Tobias Kaefer <tobias@tkaefer.de>

WORKDIR /var/www
RUN apk --no-cache add curl git supervisor curl-dev libcurl sed libpng-dev \
  postgresql-dev openldap-dev libmcrypt-dev \
  && docker-php-ext-install curl gd json pgsql ldap mysqli mcrypt pdo_pgsql pdo_mysql pcntl \
  && curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
  && chown www-data:www-data -R /var/www \
  && git clone https://github.com/hydrian/TTRSS-Auth-LDAP.git /TTRSS-Auth-LDAP \
  && cp -r /TTRSS-Auth-LDAP/plugins/auth_ldap plugins/ \
  && ls -la /var/www/plugins \
  && cp config.php-dist config.php

# expose only nginx HTTP port
EXPOSE 9000

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss
ENV DB_HOST database
ENV DB_PORT 5432

# auth method, options are: internal, ldap
ENV AUTH_METHOD internal

ENV PHP_EXECUTABLE /usr/local/bin/php

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure.php /configure.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD entrypoint.sh /entrypoint.sh

VOLUME /var/www

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
