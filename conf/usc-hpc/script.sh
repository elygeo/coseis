#!/bin/bash

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
set > env
cat > sync.sh << END
#!/bin/bash -e
ssh $HOST 'rsync -rlpt /scratch/job/ "%(rundir)s"'
END
chmod u+x sync.sh

echo "$( date ): %(name)s started" >> log
%(pre)s
rsync -rlpt . /scratch/job
cd /scratch/job
mpiexec --mca mtl mx --mca pml cm %(command)s
#mpiexec -np %(nproc)s %(command)s
cd "%(rundir)s"
rsync -rlpt /scratch/job/ .
%(post)s
echo "$( date ): %(name)s finished" >> log

