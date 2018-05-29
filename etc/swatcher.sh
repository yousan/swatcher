#!/bin/bash

### check_dist
## Usage
## dist=$(check_dist) && echo $dist // centos
function check_dist() {
	sudo cat /etc/redhat-release    >/dev/null 2>&1 && echo "centos" && exit || \
	sudo cat /etc/lsb-release       >/dev/null 2>&1 && echo "ubuntu" && exit || \
	sudo cat /etc/debian_version    >/dev/null 2>&1 && echo "debian" && exit || \
	sudo cat /etc/fedra-release     >/dev/null 2>&1 && echo "fedora" && exit || \
	sudo echo "What the heck is this dist??"
}

# watch for ssh
DISTRIBUTION=$(check_dist)
if [[ $DISTRIBUTION =~ ubuntu || $DISTRIBUTION =~ debian ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/auth.log" | grep -v 'grep' >/dev/null || \
    sudo /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/secure.conf -t /var/log/auth.log
elif [[ $DISTRIBUTION =~ centos ]]; then
    ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/secure.conf -t/var/log/secure.log" | grep -v 'grep' >/dev/null || \
    sudo /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/secure.conf -t /var/log/secure
else
    echo "Sorry, I can handle Ubuntu and CentOS only."
    exit 1
fi


# watch for vsftpd
ps auxwwww | grep "/usr/bin/swatch -c /etc/swatch/conf/ftpd.conf -t/var/log/vsftpd.log" | grep -v 'grep' >/dev/null || \
sudo /usr/bin/swatch --daemon --awk-field-syntax ';' -c /etc/swatch/conf/ftpd.conf -t/var/log/vsftpd.log
