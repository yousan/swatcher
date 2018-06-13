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
    # Start daemons.
    DISTRIBUTION=$(check_dist)
	/var/run/swatch_*.pid > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -n "Starting swatch"
        pno=0
        for conf in /etc/swatch/*.conf
        do
            pno=`expr $pno + 1`
            if [[ $conf =~ /etc/swatch/secure.conf ]]; then
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
            --pid-file /var/run/swatch_$pno.pid \
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

stop() {
    # Stop daemons.
    ls /var/run/swatch_*.pid > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -n "Shutting down swatch"
        for pid in /var/run/swatch_*.pid
        do
           kill $(cat $pid)
           rm -f $pid
        done
        echo
        rm -f /var/lock/subsys/swatch /tmp/.swatch_script.*
    else
        echo "swatch is not running"
    fi
}

status() {
    ls /var/run/swatch_*.pid > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -n "swatch (pid"
        for pid in /var/run/swatch_*.pid
        do
           echo -n " `cat $pid`"
        done
        echo ") is running..."
    else
        echo "swatch is stopped"
    fi
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        start
        ;;
  status)
        status
        ;;
   *)
        echo "Usage: swatch {start|stop|restart|status}"
        exit 1
esac

exit $RETVAL
