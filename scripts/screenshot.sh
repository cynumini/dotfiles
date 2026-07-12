#!/usr/bin/sh

DIR=$HOME/pictures/screenshots/$(date +"%Y-%m")
FILE_PNG=$DIR/$(date +"%FT%H_%M_%S").png
FILE_JXL=$DIR/$(date +"%FT%H_%M_%S").jxl

mkdir -p $DIR
grim $FILE_PNG
cjxl $FILE_PNG $FILE_JXL
rm $FILE_PNG
