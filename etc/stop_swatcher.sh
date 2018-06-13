#!/bin/bash
#
# swatch
#
# chkconfig: 2345 90 35
# description: swatch start/stop script

PATH=/sbin:/usr/local/bin:/bin:/usr/bin

mkdir -p /var/log/swatch

### check_dist
## Usage
## dist=$(check_dist) && echo $dist // centos
check_dist() {
	sudo cat /etc/redhat-release    >/dev/null 2>&1 && echo "centos" && exit || \
	sudo cat /etc/lsb-release       >/dev/null 2>&1 && echo "ubuntu" && exit || \
	sudo cat /etc/debian_version    >/dev/null 2>&1 && echo "debian" && exit || \
	sudo cat /etc/fedra-release     >/dev/null 2>&1 && echo "fedora" && exit || \
	sudo echo "What the heck is this dist??"
}

stop() {
    # Stop daemons.
    ls /var/run/swatcher_*.pid > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        for pid in /var/run/swatcher_*.pid
        do
	       pname=$($(echo basename $pid) | sed -e 's/.pid//g' | sed -e 's/swatcher_//g')
           echo -n "Stopping swatcher for $pname ..."
           kill $(cat $pid)
           rm -f $pid
        done
        echo
        rm -f /var/lock/subsys/swatch /tmp/.swatch_script.*
    else
        echo "swatch is not running"
    fi
}

stop
#exit $RETVAL
exit 0;
