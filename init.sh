#!/bin/bash
function check_permittion() {
	sudo echo $(tput setaf 2)"Starting configuration for 'swatcher'"$(tput sgr0)
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

function install_swatch() {
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

function set_config() {
    SWATCHER_CONFIG_DIR=/etc/swatcher
    SWATCHER_CONFIG_FILE=swatcher.conf
    [ ! -d $SWATCHER_CONFIG_DIR ] && mkdir -p $SWATCHER_CONFIG_DIR && cd $SWATCHER_CONFIG_DIR

cat <<'EOT' | sudo tee $SWATCHER_CONFIG_DIR/$SWATCHER_CONFIG_FILE
# Targets
# Now available 'ftp' and 'ssh' only.
# Default is 'true'
ftp=true
ssh=true


# Slack posted channel ( MAKE SURE PUT '#' at a head!!)
post_channel=#bot
# Slack Incoming Webhook URL
webhook_url=<YOUR_INCOMING_WEBHOOK_URL>
EOT

	# Replace webhook key
    echo ${YOUR_INCOMING_WEBHOOK_URL:="<YOUR_INCOMING_WEBHOOK_URL>"}
    if [ $YOUR_INCOMING_WEBHOOK_URL = "<YOUR_INCOMING_WEBHOOK_URL>" ]; then
        echo $(tput setaf 3)"[WARNING] You should change '<YOUR_INCOMING_WEBHOOK_URL>' in '/etc/swatcher/swatcher.conf' if you didn't set 'YOUR_INCOMING_WEBHOOK_URL' when installing."$(tput sgr0)
    fi
	sudo sed -i -e "s@<YOUR_INCOMING_WEBHOOK_URL>@$YOUR_INCOMING_WEBHOOK_URL@g" $SWATCHER_CONFIG_DIR/$SWATCHER_CONFIG_FILE


    echo $(tput setaf 2)"saved conf file into $SWATCHER_CONFIG_DIR"$(tput sgr0)
}

function set_target() {
    SWATCHER_TARGET_DIR=/etc/swatcher/target
    [ ! -d $SWATCHER_TARGET_DIR ] && mkdir -p $SWATCHER_TARGET_DIR && cd $SWATCHER_TARGET_DIR

	secure_conf
	ftpd_conf

    echo $(tput setaf 2)"saved conf files into $SWATCHER_TARGET_DIR/"$(tput sgr0)
}

function secure_conf() {
	SWATCHER_TARGET_DIR=/etc/swatcher/target
	SWATCHER_TARGET_FILE=secure.conf
	cat <<'EOT' | sudo tee $SWATCHER_TARGET_DIR/$SWATCHER_TARGET_FILE
watchfor /Accepted/
        exec "\/usr\/local\/bin\/slack_notify $* > /dev/null 2>&1"

### ssh失敗検知
#watchfor /Invalid user/
#        exec "\/usr\/local\/bin\/slack_notify $* > /dev/null 2>&1"

### ssh失敗検知
#watchfor /Failed/
#        exec "\/usr\/local\/bin\/slack_notify $* > /dev/null 2>&1"

### sudo実行検知
watchfor /.*COMMAND.*/
         exec "\/usr\/local\/bin\/slack_notify $* > /dev/null 2>&1"
EOT
	chmod 0644 $SWATCHER_TARGET_DIR/$SWATCHER_TARGET_FILE
}

function ftpd_conf() {
	SWATCHER_TARGET_DIR=/etc/swatcher/target
	SWATCHER_TARGET_FILE=ftpd.conf
	cat <<'EOT' | sudo tee $SWATCHER_TARGET_DIR/$SWATCHER_TARGET_FILE
# logfile /var/log/vsftpd.log

# ftp ログイン
watchfor /OK LOGIN/
         exec "\/usr\/local\/bin\/slack_notify $* > /dev/null 2>&1"
EOT
	sudo chmod 0644 $SWATCHER_TARGET_DIR/$SWATCHER_TARGET_FILE
}

function set_notify_script() {
    SLACK_NOTIFY_SCRIPT_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/slack_notify.sh"
    ACTION_SCRIPT_DEST=/usr/local/bin

    curl $SLACK_NOTIFY_SCRIPT_URL | sudo tee $ACTION_SCRIPT_DEST/slack_notify
    sudo chmod 0755 /usr/local/bin/slack_notify

    echo $(tput setaf 2)"saved into /usr/bin/slack_notify"$(tput sgr0)
}

# deprecated
function set_crontab() {
    SWATCH_CRON_UBUNTU_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.ubuntu"
    SWATCH_CRON_CENTOS_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.centos"

    DISTRIBUTION=$(check_dist)
    if [[ $DISTRIBUTION =~ ubuntu || $DISTRIBUTION =~ debian ]]; then
        curl $SWATCH_CRON_UBUNTU_URL > /etc/cron.d/swatchron
    elif [[ $DISTRIBUTION =~ centos ]]; then
        curl $SWATCH_CRON_CENTOS_URL > /etc/cron.d/swatchron
    else
        echo $(tput setaf 1)"Sorry, I can handle Ubuntu and CentOS only."$(tput sgr0)
        exit 1
    fi
    sudo chmod 0644 /etc/cron.d/swatchron

    echo $(tput setaf 2)"saved into /etc/cron.d/swatchron"$(tput sgr0)

}

function set_systemd() {
	# set start/stop script before,
	set_start_script
	set_stop_script


	SYSTEMD_DIR=/etc/systemd/system
	SWATCHER_UNIT=swatcher.service
	cat <<'EOT' | sudo tee $SYSTEMD_DIR/$SWATCHER_UNIT
[Unit]
Description=swatch daemon
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/etc/init.d/start_swatcher.sh
;ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/etc/init.d/stop_swatcher.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOT
	chmod 0755 $SYSTEMD_DIR/$SWATCHER_UNIT
	sudo systemctl daemon-reload

	echo $(tput setaf 2)"Complete configuration for swatcher.service on systemd"$(tput sgr0)
	echo $(tput setaf 2)"You can check it loaded successfully using 'sudo systemctl status swatcher'"$(tput sgr0)
}

function set_start_script() {
    SCRIPT_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/start_swatcher.sh"
    ACTION_SCRIPT_DEST=/etc/init.d

    curl $SCRIPT_URL | sudo tee $ACTION_SCRIPT_DEST/start_swatcher.sh
    sudo chmod 0755 $ACTION_SCRIPT_DEST/start_swatcher.sh

    echo $(tput setaf 2)"saved into $ACTION_SCRIPT_DEST/start_swatcher.sh "$(tput sgr0)
}
function set_stop_script() {
    SCRIPT_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/stop_swatcher.sh"
    ACTION_SCRIPT_DEST=/etc/init.d

    curl $SCRIPT_URL | sudo tee $ACTION_SCRIPT_DEST/stop_swatcher.sh
    sudo chmod 0755 $ACTION_SCRIPT_DEST/start_swatcher.sh

    echo $(tput setaf 2)"saved into $ACTION_SCRIPT_DEST/stop_swatcher.sh"$(tput sgr0)
}

function setting_ftp_log() {
	if [ "$(systemctl is-active --quiet vsftpd && echo 0)" != 0 ]; then
		echo $(tput setaf 1)"[ERROR] 'vsftpd' doesn't active. or systemctl isn't exist. "$(tput sgr0)
		return
	fi

	# デフォルト`/etc/vsftpd.conf`にない場合は`/etc/vsftpd/vsftpd.conf`を探す
	sudo sed -i -e "s/[#]*xferlog_std_format=YES/xferlog_std_format=NO/g" /etc/vsftpd.conf 2>/dev/null || \
	sudo sed -i -e "s/[#]*xferlog_std_format=YES/xferlog_std_format=NO/g" /etc/vsftpd/vsftpd.conf

	sudo sed -i -e "s@[#]*xferlog_file=/var/log/xferlog@xferlog_file=xferlog_file=/var/log/vsftpd.log@g" /etc/vsftpd.conf 2>/dev/null || \
	sudo sed -i -e "s@[#]*xferlog_file=/var/log/xferlog@xferlog_file=/var/log/vsftpd.log@g" /etc/vsftpd/vsftpd.conf

	sudo touch /var/log/vsftpd.log

	sudo systemctl restart vsftpd.service
}



function run_swatcher() {
	curl https://raw.githubusercontent.com/yousan/swatcher/master/etc/swatcher.sh | sudo bash -
}

# do
check_permittion
install_swatch
set_target
set_config
set_notify_script
setting_ftp_log
set_systemd


echo $(tput setaf 2)"Complete configuration for 'swatcher'"$(tput sgr0)

