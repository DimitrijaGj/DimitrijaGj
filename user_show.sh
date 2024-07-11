#!/bin/bash
shopt -s extglob
echo "$(date '+%Y/%m/%d %H:%M:%S') - Install zScaler CA into local users cacerts"

for d in /Users/!(Shared|.localized)/
do
    if [ -d "$d" ]; then
	echo $d
        mkdir -p "$d.test"
	echo "$dd.test"
    fi
done

