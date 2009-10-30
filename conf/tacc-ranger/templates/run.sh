#!/bin/bash -e

mode=%(mode)r
cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
case "$mode${1:--i}" in
    s-i)  /usr/bin/time -p %(bin)s ;;
    s-g)  gdb %(bin)s ;;
    s-pg) pgdb %(bin)s ;;
esac
%(post)s
echo "$( date ): %(name)s finished" >> log

