#!/bin/bash -e

mode=%(mode)r
cd %(rundir)r

echo "$( date ): %(name)s started" >> log
%(pre)s
case "$mode${1:--i}" in
    s-i)   %(bin)s ;;
    s-g)   gdb %(bin)s ;;
    s-pg)  pgdbg %(bin)s ;;
    s-ddd) ddd %(bin)s ;;
    m-i)   mpirun -machinefile mf -np %(nproc)s %(bin)s ;;
    m-g)   mpirun -machinefile mf -np %(nproc)s -dbg=gdb %(bin)s ;;
esac
%(post)s
echo "$( date ): %(name)s finished" >> log

