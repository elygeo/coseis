#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s:myri
#PBS -l walltime=%(walltime)s
#PBS -e %(rundir)s/stderr
#PBS -o %(rundir)s/stdout
#PBS -m abe
#PBS -V

cd "%(rundir)s"
rsync -rlpt . /scratch/job
cd /scratch/job
( while :; do sleep 600; rsync -rlpt . "%(rundir)s" ) &
pid=$!

echo "$( date ): %(name)s started" >> log
%(pre)s
mpiexec -np %(nproc)s %(bin)s
%(post)s
echo "$( date ): %(name)s finished" >> log

kill $pid
rsync -rlpt . "%(rundir)s"

