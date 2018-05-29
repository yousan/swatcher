#!/bin/bash
USERNAME="SERVER GATEKEEPER"
CHANNEL="#bot"
ICON=":eye:"
TEXT=$*
WEBHOOK_URL="<YOUR_INCOMING_WEBHOOK_URI>"

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
