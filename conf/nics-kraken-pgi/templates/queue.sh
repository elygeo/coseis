#!/bin/bash -e

cd %(rundir)r
if [ $( /bin/pwd | grep -v lustre ) ]; then
    echo "Error: jobs must be run from /lustre"
    exit
fi

pid="$( qsub script.sh )"
echo "$( date ): %(name)s queued with ID: $pid" >> log
echo "$pid"

