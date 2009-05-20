#!/bin/bash -e

cd %(rundir)r
if [ $( /bin/pwd | grep -v luster ) ]; then
    echo "Error: jobs must be run from /luster"
    exit
fi

echo "$( date ): %(name)s queued with ID: $( qsub script.sh )" >> log

