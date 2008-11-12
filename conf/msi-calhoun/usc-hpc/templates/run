#!/bin/bash -e

mode=%(mode)r

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
case "$mode${1:--i}" in
    s-i) time %(bin)s ;;
    s-g) gdb  %(bin)s ;;
    m-i) mpiexec -np %(np)s time %(bin)s ;;
esac
%(post)s
echo "$( date ): %(code)s finished" >> log

