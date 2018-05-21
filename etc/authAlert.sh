#!/bin/bash
USERNAME="SERVER GATEKEEPER"
CHANNEL="#bot"
ICON=":golem:"
TEXT=$*
WEBHOOK_URL="https://hooks.slack.com/services/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"

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
