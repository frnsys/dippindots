#!/bin/bash

# process new emails
notmuch new

# send notification if new emails
UNREAD=$(notmuch count "tag:unread AND folder:INBOX")
if [ -f /tmp/unread ]; then
    PAST_UNREAD=$(cat /tmp/unread)
else
    PAST_UNREAD=0
fi
if (( $UNREAD > $PAST_UNREAD )); then
    notify-send "New emails: ${UNREAD} unread"
fi
echo $UNREAD > /tmp/unread