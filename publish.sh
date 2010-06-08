#!/bin/bash -e

dest="earth.usc.edu:public_html/coseismic"

echo "Syncing to $dest"
rsync \
    -vrlpt \
    --delete \
    --delete-excluded \
    --exclude-from=.ignore \
    -e ssh \
    . "$dest"

