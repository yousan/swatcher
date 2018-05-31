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
Above installation automatically run `swatcher`. If you run `swatcher` manually, you can use below command.
```bash
curl https://raw.githubusercontent.com/yousan/swatcher/master/etc/swatcher.sh | sudo bash -
```

# Japanese Explanation (by [yousan](https://github.com/yousan))
https://qiita.com/yousan/items/e89603ba1c638be5f1c7
