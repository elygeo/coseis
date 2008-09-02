#!/bin/bash

cd %(rundir)r
if [ $( /bin/pwd | grep -v gpfs ) ]; then
    echo "Error: jobs must be run from /gpfs"
    exit
fi

echo "$( date ): %(code)s qued with ID: $( qsub script )" >> log

