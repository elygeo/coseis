#!/bin/bash

#PBS -N %(name)s
#PBS -M %(email)s
#PBS -q %(queue)s
#PBS -l nodes=%(nodes)s:ppn=%(ppn)s:myri
#PBS -l walltime=%(walltime)s
#PBS -e %(rundir)s/%(name)s-err
#PBS -o %(rundir)s/%(name)s-out
#PBS -m abe
#PBS -V

cd "%(rundir)s"
set > env
cat > sync.sh << END
#!/bin/bash -e
ssh $HOST 'rsync -rlptv /scratch/job/ "%(rundir)s"'
END
chmod u+x sync.sh

echo "$( date ): %(name)s started" >> log
%(pre)s
rsync -rlpt . /scratch/job
cd /scratch/job
mpiexec --mca mtl mx --mca pml cm %(command)s
cd "%(rundir)s"
rsync -rlpt --delete /scratch/job/ .
%(post)s
echo "$( date ): %(name)s finished" >> log

rm sync.sh

