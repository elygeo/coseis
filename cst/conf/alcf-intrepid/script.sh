#!/bin/sh

# %(queue)s %(name)s %(nodes)s %(walltime)s %(rundir)s %(email)s

cd "%(rundir)s"
set > env

echo "$( date ): %(name)s started" >> log
%(pre)s
cobalt-mpirun -mode vn -np %(nproc)s -verbose 2 -exe %(command)s
%(post)s
echo "$( date ): %(name)s finished" >> log

