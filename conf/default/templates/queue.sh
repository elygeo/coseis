#!/bin/bash -e

cd %(rundir)r
[ "$mode" = m ] && ./mpd.sh

nice nohup ./run.sh > out.log &
pid=$!
echo "$( date ): %(name)s queued with ID: $pid" >> log
echo "$pid"

