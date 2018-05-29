# What is swather?
[swatch](http://www.linux-mag.com/id/7807/) を使って、`ssh`のログと`ftp`のログを監視し、重要なログをslackのINCOMING WEBHOOKに流してくれるツールです。

# Install
Replace `YOUR_INCOMING_WEBHOOK_URI`, then run it.
```bash
curl https://raw.githubusercontent.com/yousan/swatch/master/init.sh | \
sudo YOUR_INCOMING_WEBHOOK_URI=xxx bash - 
```

### and!!
You should change `<YOUR_INCOMING_WEBHOOK_URI>` in `/usr/local/bin/slack_notify.sh` if you didn't set `YOUR_INCOMING_WEBHOOK_URI` when installing.


# Run Swatcher
```bash
curl https://raw.githubusercontent.com/yousan/swatcher/master/etc/swatcher.sh | sudo bash -
```
