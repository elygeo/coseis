#!/bin/bash

conf='publish-dest'

if [ -e "$conf" ]; then
    dest=$( cat "$conf" )
    echo "Syncing to $dest"
    rsync \
        -av \
        --delete \
        --delete-excluded \
        --include=sord.tgz \
        --include=.bzr \
        --exclude-from=.ignore \
        -e ssh \
        . "$dest"
else
    echo "Error: $conf file not found."
fi

