#!/bin/bash -e

/bin/rm -rf sord-* checkpoint in

for file in *; do
  [ -s "$file" ] || rm "$file"
done

[ "x$1" = "x-f" ] && /bin/rm -rf in/ clean.sh

rmdir * 2> /dev/null

