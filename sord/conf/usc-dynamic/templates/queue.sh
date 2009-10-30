#!/bin/bash -e

cd %(rundir)r

nice nohup ./run.sh > out.log &
pid=$!
echo "$( date ): PID: $pid" >> log
echo "%(name)s tarted with PID: $pid"

