#!/usr/bin/env sh

INPUT=$(wl-paste)
OUTPUT="$HOME/pictures/wallpaper.png"

magick \( "$INPUT" -resize 1920x -blur 0x8 -gravity center -crop 1920x1080+0+0 \) \
       \( "$INPUT" -resize x1080 \) \
       -gravity center -composite "$OUTPUT"

killall swaybg &> /dev/null
nohup swaybg -i "$OUTPUT" &> /dev/null &
