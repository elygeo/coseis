#!/bin/bash -e

dest=$( cat 'publish-dest' )
echo "Syncing to $dest"
rsync \
    -vrpln \
    --delete \
    --delete-excluded \
    --include=.bzr \
    --include=sord.tgz \
    --exclude-from=.ignore \
    -e ssh \
    . "$dest"

