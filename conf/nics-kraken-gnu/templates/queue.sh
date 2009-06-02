#!/bin/bash -e

cd %(rundir)r
if [ $( /bin/pwd | grep -v lustre ) ]; then
    echo "Error: jobs must be run from /lustre"
    exit
fi

echo "$( date ): %(name)s queued with ID: $( qsub script.sh )" >> log

