#!/usr/bin/env bash

TARGET=$(echo "yara-`yara --version`")

EMPTY_FILE=/tmp/yara.empty

if [ ! -f $EMPTY_FILE ]; then
    touch $EMPTY_FILE;
fi

yara --negate --print-meta $1 ${EMPTY_FILE} | while read i; do
    author=$(echo $i | grep -Po '(?<=author=")[^",]+' | head -1);
    type=$(echo $i | grep -Po '(?<=type=")[^",]+' | head -1);
    os=$(echo $i | grep -Po '(?<=os=")[^",]+' | head -1);
    updated=$(echo $i | grep -Po '(?<=updated=")[^",]+' | head -1);
    created=$(echo $i | grep -Po '(?<=created=")[^",]+' | head -1);
    description=$(echo $i | grep -Po '(?<=description=")[^",]+' | head -1);
    tlp=$(echo $i | grep -Po '(?<=tlp=")[^",]+' | head -1);
    echo "${created},${updated},${TARGET},${os},${type},${tlp},${author},${description},$1"
done
