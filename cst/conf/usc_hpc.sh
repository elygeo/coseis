#!/bin/bash

#PBS -N {name}
#PBS -M {email}
#PBS -q {queue}
#PBS -l nodes={nodes}:ppn={ppn}:myri
#PBS -l walltime={walltime}
#PBS -e {rundir}/{code}.error
#PBS -o {rundir}/{code}.output
#PBS -m n
#PBS -V

cd "{rundir}"
env > {code}.env
echo "$( date ): {code} started" >> {code}.log
{pre}

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
rsync -rlpt . /scratch/job
cd /scratch/job

{launch}

cd "{rundir}"
rsync -rlpt --delete /scratch/job/ .
rm sync.sh

{post}
echo "$( date ): {code} finished" >> {code}.log

