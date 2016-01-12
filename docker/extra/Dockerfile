# Dockerfile

# This file is part of the loops framework.
# 
# @author Lukas <lukas@m-t.com>
# @license https://raw.githubusercontent.com/loopsframework/base/master/LICENSE
# @link https://github.com/loopsframework/base

FROM ubuntu:15.04

# Install required packages

RUN apt-get update                                      && \
    apt-get --yes upgrade                               && \
    apt-get --yes install php5-fpm                         \
                          php5-mysql                       \
                          php5-sqlite                      \
                          php5-pgsql                       \
                          php5-mcrypt                      \
                          php-apc                          \
                          nginx                            \
                          git                              \
                          supervisor                       \
                          curl                             \
                          ssl-cert                         \
                          rsyslog                          \
                          xvfb                             \
                          libxrender1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer


# Prepare loops directory

RUN mkdir /opt/loops

WORKDIR /opt/loops

# Install Loops & Extra dependencies
RUN composer create-project loopsframework/bootstrap:dev-master .               && \
    composer require loopsframework/jobs:dev-master                             && \
    composer require loopsframework/extra:dev-master                            && \
    composer require mikehaertl/phpwkhtmltopdf:^2                               && \
    composer require swiftmailer/swiftmailer:^5                                 && \
    composer require h4cc/wkhtmltopdf-amd64:^0

# Default config directives for extra libraries
RUN echo >> /opt/loops/app/config/config.ini                                    && \
    echo >> /opt/loops/app/config/config.ini                                    && \
    echo "[pdf]" >> /opt/loops/app/config/config.ini                            && \
    echo "binary      = wkhtmltopdf-amd64" >> /opt/loops/app/config/config.ini  && \
    echo "enableXvfb  = true" >> /opt/loops/app/config/config.ini

RUN mv /opt/loops/app /opt/loops/app_skeleton                                   && \
    mkdir /opt/loops/app

COPY loops/* /opt/loops/
COPY nginx/nginx.conf /etc/nginx/
COPY nginx/snippets/* /etc/nginx/snippets/
COPY supervisor/supervisord.conf /etc/supervisor/
COPY supervisor/conf.d/* /etc/supervisor/conf.d/
COPY php5-fpm/php-fpm.conf /etc/php5/fpm/
COPY php5-fpm/www.conf /etc/php5/fpm/pool.d/
COPY init.sh /


# add vendor/bin to path variable

ENV PATH /opt/loops/vendor/bin:$PATH


# setup app folder as docker volume

VOLUME "/opt/loops/app"


# run the supervisor manager

ENTRYPOINT [ "/init.sh" ]


#expose http/https port

EXPOSE 80 443