#!/bin/bash -e

cd %(rundir)r

pid="$( qsub script.sh )"
echo "$( date ): %(name)s queued with ID: $pid" >> log
echo "$pid"

