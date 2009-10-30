#!/bin/bash -e

cd '/space/gely/files/sim/sord/scripts/benchmark/run/00001'
[ "$mode" = m ] && ./mpd.sh

nice nohup ./run.sh > out.log &
pid=$!
echo "$( date ): PID: $pid" >> log
echo "00001 started with PID: $pid"

