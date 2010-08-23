#!/bin/bash -e

if pid=$( cat websims-pid 2> /dev/null ); then
    if kill "$pid" 2> /dev/null; then
        echo "$( date ): WebSims stopped for PID: $pid" >> websims-log
        echo "$( date ): WebSims stopped for PID: $pid"
    fi
    rm -f websims-pid
fi

nohup python -c 'import cst; cst.websims.run()' "$1" >> websims-log &
pid=$!
echo "$pid" > websims-pid
echo "$( date ): WebSims started for PID: $pid" >> websims-log
echo "$( date ): WebSims started for PID: $pid"

