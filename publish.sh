#!/bin/bash -e

dest="earth.usc.edu:public_html/sord"
echo "Syncing to $dest"
rsync \
    -vrlpt \
    --delete \
    --delete-excluded \
    --include=sord.tgz \
    --include=.bzr \
    --exclude-from=.ignore \
    -e ssh \
    . "$dest"

