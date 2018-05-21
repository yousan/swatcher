#!/bin/bash

function set_config() {
    SWATCH_CONF_DIR=/etc/swatch/conf
    [ ! -d $SWATCH_CONF_DIR ] && mkdir -p $SWATCH_CONF_DIR && cd $SWATCH_CONF_DIR

    SWATCH_CONF_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/secure.conf"
    curl $SWATCH_CONF_URL > $SWATCH_CONF_DIR/secure.conf
    chmod 644 $SWATCH_CONF_DIR/secure.conf
    echo "saved into $SWATCH_CONF_DIR/secure.conf"
}

function set_script() {
    AUTH_ALERT_SCRIPT_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/authAlert.sh"
    curl $AUTH_ALERT_SCRIPT_URL > /usr/bin/authAlert.sh
    chmod 755 /usr/bin/authAlert.sh
    echo "saved into /usr/bin/authAlert.sh"
}

function set_crontab() {
    SWATCH_CRON_UBUNTU_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.ubuntu"
    SWATCH_CRON_CENTOS_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.centos"
    DISTRIBUTION=$(lsb_release -i)
    if [[ $DISTRIBUTION =~ Ubuntu  ]]; then
        curl $SWATCH_CRON_UBUNTU_URL > /etc/cron.d/swatchron
    elif [[ $DISTRIBUTION =~ CentOS ]]; then
        curl $SWATCH_CRON_CENTOS_URL > /etc/cron.d/swatchron
    else
        echo "Sorry, I can handle Ubuntu and CentOS only."
        exit 1
    fi
    echo "saved into /etc/cron.d/swatchron"
}

# do
#set_config
set_script
#set_crontab

# you can run using below command,
# ./etc/swatch.sh
