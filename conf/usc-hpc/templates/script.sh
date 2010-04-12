#!/bin/bash -e

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s:myri
#PBS -l walltime=%(walltime)s
#PBS -e stderr
#PBS -o stdout
#PBS -m abe
#PBS -V

cd %(rundir)r
echo "$( date ): %(name)s started" >> log

dir="/scratch/%(user)s/%(name)s/"
mkdir -p "$dir"
for file in %(bin)s parameters.py in out stats prof debug checkpoint; do
    mv "$file" "$dir"
done
cd "$dir"
%(pre)s
mpiexec -np %(nproc)s %(bin)s
%(post)s
mv * %(rundir)r

cd %(rundir)r
echo "$( date ): %(name)s finished" >> log

