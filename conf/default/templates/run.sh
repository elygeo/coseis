#!/bin/bash -e

mode=%(mode)r
cd %(rundir)r
[ "$mode" = m ] && ./mpd.sh

echo "$( date ): %(name)s started" >> log
%(pre)s
case "$mode${1:--i}" in
    s-i)   time %(bin)s ;;
    s-g)   gdb  %(bin)s ;;
    s-ddd) ddd  %(bin)s ;;
    m-i)   mpiexec -np %(nproc)s time %(bin)s ;;
    m-g)   mpiexec -gdb -np %(nproc)s %(bin)s ;;
    m-ddd) mpiexec -np %(nproc)s ddd  %(bin)s ;;
esac
%(post)s
echo "$( date ): %(name)s finished" >> log

