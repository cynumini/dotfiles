#!/usr/bin/env sh

if pgrep pw-record > /dev/null
then
  killall pw-record
  if [ -z "$WAYLAND_DISPLAY" ]; then
    echo file:///tmp/audio-record.opus | xclip -selection clipboard -t text/uri-list
  else
    wl-copy file:///tmp/audio-record.opus
  fi
else
  pw-record -P '{ stream.capture.sink=true }' /tmp/audio-record.opus
fi

