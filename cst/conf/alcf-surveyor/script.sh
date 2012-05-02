#!/bin/sh

cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
cobalt-mpirun -mode vn -np {nproc} -verbose 2 -exe {command}
{post}
echo "$( date ): {name} finished" >> log

