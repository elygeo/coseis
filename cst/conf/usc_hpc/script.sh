#!/bin/bash

#PBS -N {name}
#PBS -M {email}
#PBS -q {queue}
#PBS -l nodes={nodes}:ppn={ppn}:myri
#PBS -l walltime={walltime}
#PBS -e {rundir}/{name}-err
#PBS -o {rundir}/{name}-out
#PBS -m abe
#PBS -V

cd "{rundir}"
export ROMIO_HINTS="{rundir}/romio-hints"
cat > romio-hints << END
romio_cb_read enable
romio_cb_write enable
romio_ds_read disable
romio_ds_write disable
END
cat > sync.sh << END
#!/bin/bash -e
ssh $HOST 'rsync -rlptv /scratch/job/ "{rundir}"'
END
chmod u+x sync.sh
set > env

echo "$( date ): {name} started" >> log
{pre}
rsync -rlpt . /scratch/job
cd /scratch/job
mpiexec -n {nproc} {command}
cd "{rundir}"
rsync -rlpt --delete /scratch/job/ .
{post}
echo "$( date ): {name} finished" >> log

rm sync.sh

