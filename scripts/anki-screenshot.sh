#!/usr/bin/env sh

tmp_png=$(mktemp --suffix=.png)
tmp_resized=$(mktemp --suffix=.png)
tmp_avif=$(mktemp --tmpdir="$HOME/.local/share/Anki2/User 1/collection.media/" paste-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.avif)

grim -g "$(slurp)" "$tmp_png"
# spectacle -rbn -o "$tmp_png"
# maim -s "$tmp_png"
# import -screen "$tmp_png"

convert "$tmp_png" -resize 1920x400 "$tmp_resized"
avifenc -q 50 "$tmp_resized" "$tmp_avif"

wl-copy "<img src="$(basename "$tmp_avif")">"
# src=$(basename "$tmp_avif")
# echo -n "<img src=\"$src\">" | xclip -in -selection clipboard
rm -f "$tmp_png" "$tmp_resized"
