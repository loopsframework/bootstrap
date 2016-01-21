#!/bin/bash

# try to automatically set timezone based on geoip information

if [ ! $NO_IP_API_COM ]; then
    if [ ! -f /etc/localtime.bak ]; then
        TIMEZONE=`curl -s -m 5 http://ip-api.com/line | sed -n 10p`
        if [ -f /usr/share/zoneinfo/$TIMEZONE ]; then
            cp /etc/localtime /etc/localtime.bak
            cp /etc/timezone /etc/timezone.bak
            echo $TIMEZONE > /etc/timezone
            ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        fi
    fi
fi

set -e

# create syslog file (so tail won't complain on first start of container)
touch /var/log/syslog
chown syslog:adm /var/log/syslog

# logrotate after container start - save some bytes
logrotate -f /etc/logrotate.conf

# rsyslogd might not start due to pid files that were not removed
if [ -f /var/run/rsyslogd.pid ]; then
    rm /var/run/rsyslogd.pid
fi

# copy skeleton to volume if it is empty and change the files inside to user/group of the directory
if ! [ "$(ls -A /opt/loops/app)" ]; then
   cp -a /opt/loops/app_skeleton/* /opt/loops/app
   if [ "$ENABLE_JOBS" ]; then
       mkdir /opt/loops/app/inc/Jobs
   fi
   
   USER=`ls -ld /opt/loops/app | awk '{print $3}'`
   GROUP=`ls -ld /opt/loops/app | awk '{print $4}'`
   chown -R "$USER:$GROUP" /opt/loops/app
   
   echo "The app directory was empty and the default structure has been initialized."
fi


# determine and setup server name
if [ "$SERVER_NAME" ]; then
    HOSTNAME=$SERVER_NAME
else
    HOSTNAME=`hostname`
fi

echo "Using '$HOSTNAME' as 'server_name' in nginx config."


# fresh init of server configs
rm /etc/nginx/sites-enabled/*

# enable http by default
if [ ! $DISABLE_HTTP ]; then
    if [ ! -e "/etc/nginx/sites-available/$HOSTNAME" ]; then
        cp /opt/loops/nginx.template "/etc/nginx/sites-available/$HOSTNAME"
        sed -i -- "s/# server_name/server_name = $HOSTNAME;/g" "/etc/nginx/sites-available/$HOSTNAME"
    fi
    
    ln -s "/etc/nginx/sites-available/$HOSTNAME" "/etc/nginx/sites-enabled/$HOSTNAME"
    echo "HTTP traffic (port 80) is enabled."
else
    echo "HTTP traffic (port 80) is DISABLED."
fi


# force ENABLE_HTTPS if certs are found for hostname
if [ -f "/etc/nginx/certs/$HOSTNAME.key" ] && [ -f "/etc/nginx/certs/$HOSTNAME.crt" ]; then
    ENABLE_HTTPS="$HOSTNAME"
    echo "Found a crt/key for '$HOSTNAME'."
fi

# enable https if requested
if [ "$ENABLE_HTTPS" ]; then
    if [ ! -e "/etc/nginx/sites-available/$HOSTNAME-ssl" ]; then
        cp /opt/loops/nginx.template-ssl "/etc/nginx/sites-available/$HOSTNAME-ssl"
        sed -i -- "s/# server_name/server_name = $HOSTNAME;/g" "/etc/nginx/sites-available/$HOSTNAME-ssl"

        if [ -f "/etc/nginx/certs/$ENABLE_HTTPS.key" ] && [ -f "/etc/nginx/certs/$ENABLE_HTTPS.crt" ]; then
            sed -i -- "s/# key/ssl_certificate     certs\/$ENABLE_HTTPS.crt;/g" "/etc/nginx/sites-available/$HOSTNAME-ssl"
            sed -i -- "s/# crt/ssl_certificate_key certs\/$ENABLE_HTTPS.key;/g" "/etc/nginx/sites-available/$HOSTNAME-ssl"
        else
            sed -i -- "s/# snakeoil/include snippets\/snakeoil.conf;/g" "/etc/nginx/sites-available/$HOSTNAME-ssl"
            echo "Using self-signed certificate for HTTPS!"
            make-ssl-cert generate-default-snakeoil --force-overwrite
        fi
    fi

    ln -s "/etc/nginx/sites-available/$HOSTNAME-ssl" "/etc/nginx/sites-enabled/$HOSTNAME-ssl"
    echo "HTTPS traffic (port 443) is enabled."
else
    echo "HTTPS traffic (port 443) is disabled."
fi


#start services
if [ $ENABLE_JOBS ]; then
    sed -i -- "s/autostart=false/autostart=true/g" "/etc/supervisor/conf.d/loopsjobs.conf"
fi

# get our logging to stdout for docker
tail -n +0 -F /var/log/syslog &

echo "----- Starting Loops Server -----"

# run supervisor that manages all other processes
exec supervisord --configuration=/etc/supervisor/supervisord.conf --nodaemon
