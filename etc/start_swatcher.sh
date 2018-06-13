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

start() {
    DISTRIBUTION=$(check_dist)
	/var/run/swatch_*.pid > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -n "Starting swatch"
        for conf in /etc/swatch/conf/*.conf
        do
			pname=$($(echo basename $conf) | sed -e 's/.conf//g')
			echo "$pname running"
            if [[ $conf =~ /etc/swatch/conf/secure.conf ]]; then
	            if [[ $DISTRIBUTION =~ ubuntu || $DISTRIBUTION =~ debian ]]; then
	                WATCHLOG=/var/log/auth.log
				elif [[ $DISTRIBUTION =~ centos ]]; then
	                WATCHLOG=/var/log/secure
				else
		            echo "Sorry, It can handle Ubuntu, Debian and CentOS only."
		            exit 1
				fi
			else
                WATCHLOG=`grep "^# logfile" $conf | awk '{ print $3 }'`
            fi
            swatch --config-file $conf --tail-file $WATCHLOG \
            --script-dir=/tmp --awk-field-syntax --use-cpan-file-tail --daemon \
            --pid-file /var/run/swatcher_$pname.pid \
            >> /var/log/swatch/swatch.log 2>&1
            RETVAL=$?
            [ $RETVAL != 0 ] && return $RETVAL
        done
        echo
        [ $RETVAL = 0 ] && touch /var/lock/subsys/swatch
        return $RETVAL
    else
        echo "swatch is already started"
    fi
}

start
exit 0;
#exit $RETVAL
