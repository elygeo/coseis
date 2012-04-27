#!/bin/bash -e

dst="earth.usc.edu:public_html/coseis"
echo "Syncing to $dst"

rsync \
    -Pvrptl \
    --delete \
    --delete-excluded \
    --exclude-from='.gitignore' \
    -e ssh \
    . "$dst"

