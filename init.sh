#!/bin/bash
function check_permittion() {
	sudo echo $(tput setaf 2)"Starting configuration for 'swatcher'"$(tput sgr0)
	if [ $? != 0 ]; then
        echo $(tput setaf 4)"Permittion Denied"$(tput sgr0)
		exit 1
	fi
}

function check_dist() {
	sudo cat /etc/redhat-release 2>/dev/null && echo "centos" || \
	sudo cat /etc/lsb-release 2>/dev/null && echo "ubuntu" || \
	sudo cat /etc/debian_version 2>/dev/null && echo "debian" || \
	sudo cat /etc/fedra-release 2>/dev/null && echo "fedora" || \
	sudo echo "What the heck is this dist??"
}

function set_config() {
    SWATCH_CONF_DIR=/etc/swatch/conf
    [ ! -d $SWATCH_CONF_DIR ] && mkdir -p $SWATCH_CONF_DIR && cd $SWATCH_CONF_DIR

#	for f in etc/conf/*
#	do
#		conf_file=$(basename $f)
#	    curl "https://raw.githubusercontent.com/yousan/swatch/master/etc/$conf_file" > $SWATCH_CONF_DIR/$conf_file
#        chmod 0644 $SWATCH_CONF_DIR/$conf_file
#	done

	secure_conf
	ftpd_conf

    echo $(tput setaf 2)"saved conf files into $SWATCH_CONF_DIR/"$(tput sgr0)
}

function secure_conf() {
SWATCH_CONF_DIR=/etc/swatch/conf

sudo sh -c "cat <<'EOF' >> $SWATCH_CONF_DIR/swatch_for_secure.conf
	watchfor /Accepted/
	        echo
	        exec \"/usr/local/bin/slack_notify.sh $* > /dev/null 2>&1\"

	### ssh失敗検知
	#watchfor /Invalid user/
	#        echo
	#        exec \"/usr/local/bin/slack_notify.sh $* > /dev/null 2>&1\"

	### ssh失敗検知
	#watchfor /Failed/
	#        echo
	#        exec \"/usr/local/bin/slack_notify.sh $* > /dev/null 2>&1\"

	### sudo実行検知
	watchfor /.*COMMAND.*/
	         echo
	         exec \"/usr/local/bin/slack_notify.sh $* > /dev/null 2>&1\"
	EOF
	"
}

function ftpd_conf() {
	SWATCH_CONF_DIR=/etc/swatch/conf

	sudo sh -c "cat <<'EOF' >> $SWATCH_CONF_DIR/swatch_for_ftpd.conf
	# ftp ログイン
	watchfor /OK LOGIN/
	         echo
	         exec \"/usr/local/bin/slack_notify.sh $* > /dev/null 2>&1\"
	EOF
	"
}

function set_script() {
    SLACK_NOTIFY_SCRIPT_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/slack_notify.sh"
    ACTION_SCRIPT_DEST=/usr/local/bin

    curl $SLACK_NOTIFY_SCRIPT_URL | sudo tee $ACTION_SCRIPT_DEST/slack_notify.sh
    chmod 0755 /usr/local/bin/slack_notify.sh

	# Replace webhook key
    ${KEY:="<YOUR_INCOMING_WEBHOOK_URI>"}
	sudo sed -i -e "s/<YOUR_INCOMING_WEBHOOK_URI>/$KEY/g" $ACTION_SCRIPT_DEST/slack_notify.sh

    echo $(tput setaf 2)"saved into /usr/bin/slack_notify.sh"$(tput sgr0)
}

function set_crontab() {
    SWATCH_CRON_UBUNTU_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.ubuntu"
    SWATCH_CRON_CENTOS_URL="https://raw.githubusercontent.com/yousan/swatch/master/etc/swatchron.centos"
    DISTRIBUTION=check_dist
    # $($(lsb_release -i) || cat /etc/system-release)

    if [[ $DISTRIBUTION =~ ubuntu  ]]; then
        curl $SWATCH_CRON_UBUNTU_URL > /etc/cron.d/swatchron
    elif [[ $DISTRIBUTION =~ centos ]]; then
        curl $SWATCH_CRON_CENTOS_URL > /etc/cron.d/swatchron
    else
        echo $(tput setaf 4)"Sorry, I can handle Ubuntu and CentOS only."$(tput sgr0)
        exit 1
    fi
    chmod 0644 /etc/cron.d/swatchron

    echo $(tput setaf 2)"saved into /etc/cron.d/swatchron"$(tput sgr0)

}

function setting_ftp_log() {
	# デフォルト`/etc/vsftpd.conf`にない場合は`/etc/vsftpd/vsftpd.conf`を探す
	sudo sed -i -e "s/^xferlog_std_format=/#xferlog_std_format=/g" /etc/vsftpd.conf || \
	sudo sed -i -e "s/^xferlog_std_format=/#xferlog_std_format=/g" /etc/vsftpd/vsftpd.conf

	sudo sed -i -e "s/^xferlog_file=/#xferlog_file=/g" /etc/vsftpd.conf || \
	sudo sed -i -e "s/^xferlog_file=/#xferlog_file=/g" /etc/vsftpd/vsftpd.conf
}

function run_swatcher() {
	curl https://raw.githubusercontent.com/yousan/swatcher/master/etc/swatcher.sh | sudo bash -
}

# do
check_permittion
set_config
#set_crontab
set_script

setting_ftp_log

run_swatcher


echo $(tput setaf 2)"Complete configuration for 'swatcher'"$(tput sgr0)
echo $(tput setaf 3)"You should change INCOMING_WEBHOOK_URI in /usr/bin/slack_notify.sh"$(tput sgr0)

