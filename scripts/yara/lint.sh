#!/usr/bin/env bash

TARGET=yara

EMPTY_FILE=/tmp/yara.empty

STATE=0

if [ ! -f $EMPTY_FILE ]; then
    touch $EMPTY_FILE;
fi

yara --negate --print-meta $1 ${EMPTY_FILE} | while read i; do
    signature=$(echo $i | grep -Po '^[^\s]+')
    echo "[-] $signature $1"
    result=$(echo $i | grep -Po '(?<=type=")[^",]+' | head -1)
    if [ -z `echo ${result} | grep -P '^(?:(?:malware|heuristic|attack|exploit|phishing|reputation|policy|riskware)(?:[^\/]+)?\/?)+$'` ]; then
        echo "[x] $signature $1 $result is not a valid type"
        STATE=1
    fi
    result=$(echo $i | grep -Po '(?<=rev=)[^",\]]+' | head -1);
    if [ -z `echo ${result} | grep -P '^\d+$'` ]; then
        echo "[x] $signature $1 $result is not a valid rev number"
        STATE=1
    fi
    result=$(echo $i | grep -Po '(?<=updated=")[^",]+' | head -1)
    if [ ! -z $result ]; then
        if [ -z `echo ${result} | grep -P '^\d+-\d{2}-\d{2}$'` ]; then
            echo "[x] $signature $1 $result is not a valid updated date"
            STATE=1
        fi
    fi
    result=$(echo $i | grep -Po '(?<=os=")[^",]+' | head -1)
    if [ -z `echo ${result} | grep -P '^(?:(?:android|freebsd|ios|windows|linux|macos)\/?)+$'` ]; then
        echo "[x] $signature $1 $result is not a valid os"
        STATE=1
    fi
    result=$(echo $i | grep -Po '(?<=created=")[^",]+' | head -1)
    if [ -z `echo ${result} | grep -P '^\d+-\d{2}-\d{2}$'` ]; then
        echo "[x] $signature $1 $result is not a valid created date"
        STATE=1
    fi
    result=$(echo $i | grep -Po '(?<=tlp=")[^",]+' | head -1);
    if [ -z `echo ${result} | grep -P '^(white|green|amber|red)$'` ]; then
        echo "[x] $signature $1 $result is not a valid tlp"
        STATE=1
    fi
    result=$(echo $i | grep -Po '(?<=description=")[^",]+' | head -1)
    if [ ! -z $description ]; then
        echo "[x] $signature $1 missing description"
        STATE=1
    fi
    if [ $STATE -eq 1 ]; then
        exit 1;
    else
        echo "[*] $signature $1"
    fi
done
