#!/bin/sh

cd "{rundir}"
set > env

echo "$( date ): {name} started" >> log
{pre}
runjob -p {ppn} -n {nproc} --verbose 2 --block $COBALT_PARTNAME --envs BG_SHAREDMEMSIZE=32MB --envs PAMI_VERBOSE=1 ${COBALT_CORNER:+--corner} $COBALT_CORNER ${COBALT_SHAPE:+--shape} $COBALT_SHAPE : {command}
{post}
echo "$( date ): {name} finished" >> log

