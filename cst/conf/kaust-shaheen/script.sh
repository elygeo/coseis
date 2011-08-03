#!/bin/sh
# @ account_no = k33
# @ class = %(queue)s
# @ job_name = %(name)s
# @ bg_size = %(nodes)s
# @ wall_clock_limit = %(walltime)s
# @ error = %(name)s-err
# @ output = %(name)s-out
# @ initialdir = %(rundir)s
# @ notify_user = %(email)s
# @ notification = never
# @ job_type = bluegene
# @ environment = COPY_ALL
# @ queue

cd "%(rundir)s"
set > env

echo "$( date ): %(name)s started" >> log
%(pre)s
mpirun -mode VN -np %(nproc)s -exe %(command)s
%(post)s
echo "$( date ): %(name)s finished" >> log

