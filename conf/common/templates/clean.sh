#!/bin/bash -e

for file in *
do [ -s "$file" ] || rm "$file"
done

rmdir * 2> /dev/null || :
rm -rf sord-* checkpoint
[ "x$1" = "x-f" ] && rm -rf in/ clean.sh

