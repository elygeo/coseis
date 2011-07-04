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
export ROMIO_HINTS="%(rundir)s/romio-hints"
cat > romio-hints << END
romio_cb_read enable
romio_cb_write enable
romio_ds_read disable
romio_ds_write disable
END
cat > sync.sh << END
#!/bin/bash -e
ssh $HOST 'rsync -rlptv /scratch/job/ "%(rundir)s"'
END
chmod u+x sync.sh
set > env

echo "$( date ): %(name)s started" >> log
%(pre)s
rsync -rlpt . /scratch/job
cd /scratch/job
mpiexec -n %(nproc)s %(command)s
# mpiexec --mca mtl mx --mca pml cm %(command)s # OpenMPI
cd "%(rundir)s"
rsync -rlpt --delete /scratch/job/ .
%(post)s
echo "$( date ): %(name)s finished" >> log

rm sync.sh

