#!/bin/sh
# @ account_no = k33
# @ class = {queue}
# @ job_name = {name}
# @ bg_size = {nodes}
# @ wall_clock_limit = {walltime}
# @ error = {name}-err
# @ output = {name}-out
# @ initialdir = {rundir}
# @ notify_user = {email}
# @ notification = never
# @ job_type = bluegene
# @ environment = COPY_ALL
# @ queue

cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
mpirun -mode VN -np {nproc} -exe {command}
{post}
echo "$( date ): {name} finished" >> log

