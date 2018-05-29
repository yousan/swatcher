# Install
Replace `YOUR_INCOMING_WEBHOOK_URI`, then run it.
```bash
curl https://raw.githubusercontent.com/yousan/swatch/master/init.sh | \
sudo YOUR_INCOMING_WEBHOOK_URI=xxx bash - 
```

# AND!! 
You should change `<YOUR_INCOMING_WEBHOOK_URI>` in `/usr/bin/slack_notify.sh` if you didn't set `YOUR_INCOMING_WEBHOOK_URI` when installing.


# Run Swatcher
```bash
curl https://raw.githubusercontent.com/yousan/swatcher/master/etc/swatcher.sh | sudo bash -
```
