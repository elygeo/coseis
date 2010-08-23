#!/bin/bash -e

if pid=$( cat websims-pid 2> /dev/null ); then
    kill $pid
    rm -f websims-pid
    echo "$( date ): WebSims stopped for PID: $pid" >> websims-log
    echo "$( date ): WebSims stopped for PID: $pid"
fi

