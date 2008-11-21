#!/bin/bash -e

mode=%(mode)r

cd %(rundir)r
if [ $( /bin/pwd | grep -v gpfs ) ]; then
    echo "Error: jobs must be run from /gpfs"
    exit
fi

echo "$( date ): %(name)s started" >> log
%(pre)s
case "$mode${1:--i}" in
    s-i)  time %(bin)s ;;
    s-g)  gdb %(bin)s ;;
    s-tv) totalview %(bin)s ;;
    m-i)  mpirun -machinefile mf -np %(np)s %(bin)s ;;
    m-tv) mpirun -tv -machinefile mf -np %(np)s %(bin)s ;;
esac
%(post)s
echo "$( date ): %(name)s finished" >> log

