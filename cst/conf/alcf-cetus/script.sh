#!/bin/sh

# {queue} {name} {nodes} {walltime} {rundir} {email}
# qsub -t 30 -n 16 --mode script -A <your_project_name> --env BG_SHAREDMEMSIZE=32MB:PAMI_VERBOSE=1 ./myscript.sh


cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
runjob -p 16 -np 256 --block $COBALT_PARTNAME -verbose 2 --envs BG_SHAREDMEMSIZE=32MB --envs PAMI_VERBOSE=1 : myprogram.exe myprogarg
#runjob -mode vn -np {nproc} -verbose 2 -exe {command}
{post}
echo "$( date ): {name} finished" >> log

