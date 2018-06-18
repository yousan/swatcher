# What is swather?
`Swatcher` is a log watching tool that send important and specified logs to `slack INCOMING WEBHOOK` using [swatch](http://www.linux-mag.com/id/7807/). It corresponds now to `ssh` log and` ftp` log.

# Install
Replace `YOUR_INCOMING_WEBHOOK_URL`, then run it.
```bash
curl https://raw.githubusercontent.com/yousan/swatch/master/init.sh | \
sudo YOUR_INCOMING_WEBHOOK_URL=xxx bash - 
```

### and!!
You should change `<YOUR_INCOMING_WEBHOOK_URL>` in `/etc/swatcher/swatcher.conf` if you didn't set `YOUR_INCOMING_WEBHOOK_URL` when installing.


### Check if `swatcher` is loaded successfully 
The `swatcher` uses `systemd`. You can sure that systemd loaded `swatcher` successfully as a unit, using `sudo systemctl status swatcher` command. If it's status is `loaded`, it success loading `swatcher.service`.
![Successfully loaded](https://raw.githubusercontent.com/yousan/swatcher/master/assets/successfully_loaded.png?raw=true)


# Run Swatcher 
After you check that, run typing below command.
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

# Auto start when reboot
```bash
sudo systemctl enable swatcher
```

# Uninstall
If you uninstall swatcher, you can run this
```bash
curl https://raw.githubusercontent.com/yousan/swatch/master/uninit.sh | \
sudo bash -
```

# Configuration
You can change settings for swatcher on `/etc/swatcher/swatcher.conf`.


# Japanese Explanation (by [yousan](https://github.com/yousan))
https://qiita.com/yousan/items/e89603ba1c638be5f1c7
