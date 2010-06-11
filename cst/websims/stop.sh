#!/bin/bash -e
# Stop app

cd $( dirname $0 )

if pid=$( cat pid 2> /dev/null ); then
    kill $pid
    rm -f pid
    echo "$( date ): app stopped for PID: $pid" >> log
    echo "$( date ): app stopped for PID: $pid"
fi

