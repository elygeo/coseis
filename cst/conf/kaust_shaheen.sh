#!/bin/sh

# @ account_no = {account}
# @ class = {queue}
# @ job_name = {name}
# @ bg_size = {nodes}
# @ wall_clock_limit = {walltime}
# @ error = {code}.error
# @ output = {code}.output
# @ initialdir = {rundir}
# @ notify_user = {email}
# @ notification = never
# @ job_type = bluegene
# @ environment = COPY_ALL
# @ queue

cd "{rundir}"
env >> {code}.env

echo "$( date ): {code} started" >> {code}.log
{pre}
{launch}
{post}
echo "$( date ): {code} finished" >> {code}.log

