#!/bin/bash -e
# Start app

cd $( dirname $0 )

if pid=$( cat pid 2> /dev/null ); then
    if kill "$pid" 2> /dev/null; then
        echo "$( date ): app stopped for PID: $pid" >> log
        echo "$( date ): app stopped for PID: $pid"
    fi
    rm -f pid
fi

nohup ./app.py >> log &
pid=$!
echo "$pid" > pid
echo "$( date ): app started for PID: $pid" >> log
echo "$( date ): app started for PID: $pid"

