#!/bin/bash -e

cd %(rundir)r
if [ $( /bin/pwd | grep -v gpfs ) ]; then
    echo "Error: jobs must be run from /gpfs"
    exit
fi

echo "$( date ): %(name)s queued with ID: $( qsub script.sh )" >> log

