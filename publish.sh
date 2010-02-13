#!/bin/bash -e

dest="earth.usc.edu:public_html/sord"

echo "Syncing to $dest"
rsync \
    -vrlpt \
    --delete \
    --delete-excluded \
    --include=.bzr \
    --include=sord.tgz \
    --exclude-from=.ignore \
    -e ssh \
    . "$dest"

