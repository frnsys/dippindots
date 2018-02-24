#!/bin/bash

declare -A tags
tags[expense]=Labels.Expense
tags[donation]=Labels.Donation
tags[upcoming]=Labels.Upcoming

# process new emails
notmuch new

# auto-tag based on maildir folder
for tag in "${!tags[@]}"; do
    echo "Tagging ${tags[$tag]} -> $tag"
    notmuch tag +$tag -- folder:${tags[$tag]} and -tag:$tag
done

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