#!/bin/bash -e

/bin/rm -rf scecvm checkpoint input sord-*
for file in *; do [ -s "$file" ] || rm "$file"; done
[ "x$1" = "x-f" ] && /bin/rm -rf data clean
rmdir * 2> /dev/null

