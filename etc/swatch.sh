#!/bin/bash

DISTRIBUTION=$(lsb_release -i)
if [[ $DISTRIBUTION =~ Ubuntu  ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/auth.log" | grep -v 'grep' >/dev/null || /usr/bin/swatch --daemon --awk-field-syntax / -c /etc/swatch/conf/secure.conf -t /var/log/auth.log
elif [[ $DISTRIBUTION =~ CentOS ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/auth.log" | grep -v 'grep' >/dev/null || /usr/bin/swatch --daemon --awk-field-syntax / -c /etc/swatch/conf/secure.conf -t /var/log/secure
else
    echo "Sorry, I can handle Ubuntu and CentOS only."
    exit 1
fi
