#!/bin/bash

#PBS -N %(code)s%cound)s
#PBS -l nodes=%(nodes):ppn=%(ppn):smallmem
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -M %(email)s
#PBS -V

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
/home/doug/bin/clean_ipc_r $( cat $PBS_NODEFILE )
mpiexec -kill -np %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

