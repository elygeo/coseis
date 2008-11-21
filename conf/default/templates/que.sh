#!/bin/bash -e

cd %(rundir)r
[ "$mode" = m ] && ./mpd.sh

nice nohup ./run.sh > out.log &
pid=$!
echo "$( date ): PID: $pid" >> log
echo "%(name)s started with PID: $pid"

