#!/bin/bash
USERNAME="SERVER GATEKEEPER"
#CHANNEL="#bot"
tmp=$(cat /etc/swatcher/swatcher.conf | grep post_channel)
CHANNEL=${tmp#*=}
ICON=":eye:"
TEXT=$*
#WEBHOOK_URL="https://hooks.slack.com/services/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"
tmp=$(cat /etc/swatcher/swatcher.conf | grep webhook_url)
WEBHOOK_URL=${tmp#*=}

author="sa9sha9"

data=`cat << EOF
    payload={
    "channel": "$CHANNEL",
    "username": "$USERNAME",
    "icon_emoji": "$ICON",
    "link_names": 1 ,
    "attachments": [{
        "text": "$TEXT"
      }]
  }
EOF`

curl -X POST --data-urlencode "$data" $WEBHOOK_URL