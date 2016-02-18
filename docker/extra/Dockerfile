# Dockerfile

# This file is part of the loops framework.
# 
# @author Lukas <lukas@m-t.com>
# @license https://raw.githubusercontent.com/loopsframework/base/master/LICENSE
# @link https://github.com/loopsframework/base

FROM loopsframework/base:dev

# Install required packages

RUN apt-get update                                      && \
    apt-get --yes upgrade                               && \
    apt-get --yes install xvfb                             \
                          libxrender1

# Install Extra dependencies
RUN composer require loopsframework/extra:dev-master                            && \
    composer require mikehaertl/phpwkhtmltopdf:^2                               && \
    composer require swiftmailer/swiftmailer:^5                                 && \
    composer require h4cc/wkhtmltopdf-amd64:^0

# Default config directives for extra libraries
RUN echo ""                                 >> /opt/loops/app_skeleton/config/config.ini    && \
    echo ""                                 >> /opt/loops/app_skeleton/config/config.ini    && \
    echo "[pdf]"                            >> /opt/loops/app_skeleton/config/config.ini    && \
    echo "binary      = wkhtmltopdf-amd64"  >> /opt/loops/app_skeleton/config/config.ini    && \
    echo "enableXvfb  = true"               >> /opt/loops/app_skeleton/config/config.ini