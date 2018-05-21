#!/bin/bash
sudo su -

SWATCH_CONF_DIR=/etc/swatch/conf
[ ! -d $SWATCH_CONF_DIR ] && mkdir -p $SWATCH_CONF_DIR && cd $SWATCH_CONF_DIR

SWATCH_CONF_URL=HOGE
curl $SWATCH_CONF_URL > secure.conf
chmod 644 $SWATCH_CONF_DIR/secure.conf

ALERT_SCRIPT_URL=FUGA
curl $ALERT_SCRIPT_URL > /usr/bin/alertAuth.sh
chmod 755 /usr/bin/alertAuth.sh

SWATCH_CRON_UBUNTU_URL=FAA
SWATCH_CRON_CENTOS_URL=FAA
DISTRIBUTION=$(lsb_release -i)
if [[ $DISTRIBUTION =~ Ubuntu  ]]; then
    curl $SWATCH_CRON_UBUNTU_URL > /etc/cron.d/swatchron.ubuntu
elif [[ $DISTRIBUTION =~ CentOS ]]; then
    curl $SWATCH_CRON_CENTOS_URL > /etc/cron.d/swatchron.centos
else
    echo "Sorry, I can handle Ubuntu and CentOS only."
    exit 1
fi

# you can run using below command,
# swatch -c /etc/swatch/conf/secure.conf -t /var/log/auth.log -t /var/log/auth.log&watch --awk-field-syntax /

exit
