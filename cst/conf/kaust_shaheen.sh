#!/bin/sh

# @ account_no = {account}
# @ class = {queue}
# @ job_name = {name}
# @ bg_size = {nodes}
# @ wall_clock_limit = {walltime}
# @ error = {name}.err
# @ output = {name}.out
# @ initialdir = {rundir}
# @ notify_user = {email}
# @ notification = never
# @ job_type = bluegene
# @ environment = COPY_ALL
# @ queue

cd "{rundir}"
env >> {name}.env

echo "$( date ): {name} started" >> {name}.out
{pre}
{launch}
{post}
echo "$( date ): {name} finished" >> {name}.out

