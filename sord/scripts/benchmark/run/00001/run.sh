#!/bin/bash -e

mode='m'
cd '/space/gely/files/sim/sord/scripts/benchmark/run/00001'
[ "$mode" = m ] && ./mpd.sh

echo "$( date ): 00001 started" >> log

case "$mode${1:--i}" in
    s-i)   time ./sord-mO ;;
    s-g)   gdb  ./sord-mO ;;
    s-ddd) ddd  ./sord-mO ;;
    m-i)   mpiexec -np 1 time ./sord-mO ;;
    m-g)   mpiexec -gdb -np 1 ./sord-mO ;;
    m-ddd) mpiexec -np 1 ddd  ./sord-mO ;;
esac

echo "$( date ): 00001 finished" >> log

