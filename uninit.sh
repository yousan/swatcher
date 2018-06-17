#!/bin/bash
function check_permittion() {
	sudo echo $(tput setaf 2)"Starting deletion of 'swatcher'"$(tput sgr0)
	if [ $? != 0 ]; then
        echo $(tput setaf 1)"Permittion Denied"$(tput sgr0)
		exit 1
	fi
}

function check_dist() {
	sudo cat /etc/redhat-release    >/dev/null 2>&1 && echo "centos" && exit || \
	sudo cat /etc/lsb-release       >/dev/null 2>&1 && echo "ubuntu" && exit || \
	sudo cat /etc/debian_version    >/dev/null 2>&1 && echo "debian" && exit || \
	sudo cat /etc/fedra-release     >/dev/null 2>&1 && echo "fedora" && exit || \
	sudo echo "What the heck is this dist??"
}

function uninstall_swatch() {
	# インストール済みであればスキップ
	if (type "swatch" > /dev/null 2>&1); then
	    return
	fi

    DISTRIBUTION=$(check_dist)
    if [[ $DISTRIBUTION =~ ubuntu || $DISTRIBUTION =~ debian ]]; then
        yes | \
        sudo apt update && \
        sudo apt upgrade && \
		sudo apt install swatch
    elif [[ $DISTRIBUTION =~ centos ]]; then
        yes | \
        sudo yum update && \
		sudo yum install swatch
    else
        echo $(tput setaf 1)"Sorry, I can handle Ubuntu and CentOS only."$(tput sgr0)
        exit 1
    fi

}

function uninit() {
    rm -rf /etc/systemd/system/swatcher.service
    rm -rf /etc/init.d/*_swatcher.sh
    systemctl stop swatcher && \
    systemctl disable swatcher && \
    systemctl daemon-reload

    rm -rf /etc/swatch
    rm -rf /usr/local/bin/slack_notify
    rm -rf /etc/cron.d/swatchron

    # How about /var/log, /var/run?
}

# do
check_permittion
uninit

echo $(tput setaf 2)"Complete deletion of 'swatcher'"$(tput sgr0)

