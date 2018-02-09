#!/bin/bash
# script to apply custom styles to html emails
# and proper character encoding

HTML=$(cat $1)
HEAD="
<meta charset='utf-8'>
<style>
html, body {
  margin: 0 auto;
  padding: 1em;
  max-width: 680px;
  font-family: 'Graphik', sans-serif;
  line-height: 1.4;
}
img {
  max-width: 100%;
  height: auto;
}
</style>
"

echo -e "$HEAD\n$HTML" > /tmp/view_html
bspc rule -a Nightly -o state=floating center=on rectangle=1000x800+0+0
firefox -new-window /tmp/view_html