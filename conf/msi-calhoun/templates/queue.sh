#!/bin/bash -e

cd %(rundir)r
echo "$( date ): %(name)s queued with ID: $( qsub script.sh )" >> log

