#!/bin/bash -e

dest="earth.usc.edu:public_html/coseis"

if [ "$( basename $PWD )" != "release" ]; then
    echo "Must run from coseis/release directory"
    exit
fi

echo "Syncing to $dest"

rsync \
    -vrlpt \
    --delete \
    --delete-excluded \
    --exclude-from=.pubignore \
    -e ssh \
    . "$dest"

