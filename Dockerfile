# Temporary dockerfile

FROM ubuntu:15.04


# Install required packages

#libpcre3-dev                     \

RUN apt-get update                                      && \
    apt-get --yes upgrade                               && \
    apt-get --yes install php5-fpm                         \
                          php5-mysql                       \
                          php5-sqlite                      \
                          php5-pgsql                       \
                          php5-memcache                    \
                          php5-mcrypt                      \
                          nginx                            \
                          git                              \
                          supervisor                       \
                          curl                             \
                          ssl-cert                         \
                          rsyslog

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer


# Prepare loops directory

RUN mkdir /opt/loops && mkdir /opt/loops/app

WORKDIR /opt/loops
    
COPY docker/loops/* /opt/loops/
COPY docker/nginx/nginx.conf /etc/nginx/
COPY docker/nginx/snippets/* /etc/nginx/snippets/
COPY docker/supervisor/supervisord.conf /etc/supervisor/
COPY docker/supervisor/conf.d/* /etc/supervisor/conf.d/
COPY docker/php5-fpm/php-fpm.conf /etc/php5/fpm/
COPY docker/php5-fpm/www.conf /etc/php5/fpm/pool.d/
COPY docker/init.sh /


#temporary fix until loops2 is live on github
COPY / /tmp/loops
RUN composer install


# add vendor/bin to path variable

ENV PATH /opt/loops/vendor/bin:$PATH


# setup app folder as docker volume

VOLUME "/opt/loops/app"


# run the supervisor manager

ENTRYPOINT [ "/init.sh" ]


#expose http/https port

EXPOSE 80 443