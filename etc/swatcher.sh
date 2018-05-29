#!/bin/bash

# watch for ssh
DISTRIBUTION=$(lsb_release -i)
if [[ $DISTRIBUTION =~ Ubuntu  ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/auth.log" | grep -v 'grep' >/dev/null ||
     /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/secure.conf -t /var/log/auth.log
     # --awk-field-syntaxは'\n'以外であれば何でもいい. ';'を終了文字として読み込まなければ。
elif [[ $DISTRIBUTION =~ CentOS ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/auth.log" | grep -v 'grep' >/dev/null || /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/secure.conf -t /var/log/secure
else
    echo "Sorry, I can handle Ubuntu and CentOS only."
    exit 1
fi


# watch for vsftpd
ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/swatch_for_vsftpd.conf -t/var/log/vsftpd.log" | grep -v 'grep' >/dev/null ||
 /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/swatch_for_vsftpd.conf -t/var/log/vsftpd.log
