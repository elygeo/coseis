#!/bin/bash -e

#PBS -N %(code)s%(count)s
#PBS -l nodes=%(nodes)s:myri:ppn=%(ppn)s
#PBS -l walltime=%(walltime)s
##PBS -q main
##PBS -q large
##PBS -q quick
#PBS -q scec
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -M %(email)s
#PBS -V

#dir=$( baseanem %(rundir)r )
#mv %(rundir)r /scratch/
#cd "/scratch/$dir"

cd %(rundir)r

echo "$( date ): %(code)s started" >> log
%(pre)s
mpiexec -np %(np)s %(bin)s
%(post)s
echo "$( date ): %(code)s finished" >> log

#mv "/scratch/$dir" %(rundir)r

