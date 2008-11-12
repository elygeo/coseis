#!/bin/bash -e

cd %(rundir)r

nice nohup ./run > out.log &
pid=$!
echo "$( date ): PID: $pid" >> log
echo "%(code)s started with PID: $pid"

