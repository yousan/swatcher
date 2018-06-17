# What is swather?
`Swatcher` is a log watching tool that send important and specified logs to `slack INCOMING WEBHOOK` using [swatch](http://www.linux-mag.com/id/7807/). It corresponds now to `ssh` log and` ftp` log.

# Install
Replace `YOUR_INCOMING_WEBHOOK_URI`, then run it.
```bash
curl https://raw.githubusercontent.com/yousan/swatch/master/init.sh | \
sudo YOUR_INCOMING_WEBHOOK_URI=xxx bash - 
```

### and!!
You should change `<YOUR_INCOMING_WEBHOOK_URI>` in `/usr/local/bin/slack_notify.sh` if you didn't set `YOUR_INCOMING_WEBHOOK_URI` when installing.


# Run Swatcher
`swatcher` uses `systemd`. You can sure that systemd loaded `swatcher` successfully as a unit, using `sudo systemctl status swatcher` command. After you can check that, run below command.
```bash
sudo systemctl start swatcher
```

# Stop Swatcher
And you can stop to type a below command.
```bash
sudo systemctl stop swatcher
```

# Restart Swatcher
And also do restart.
```bash
sudo systemctl restart swatcher
```


# Japanese Explanation (by [yousan](https://github.com/yousan))
https://qiita.com/yousan/items/e89603ba1c638be5f1c7

# Future Wroks
- Configure tool so that can change settings not only when initialization
