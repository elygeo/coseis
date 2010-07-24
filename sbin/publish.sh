#!/bin/bash -e

dest="earth.usc.edu:public_html/coseis"

echo "Syncing to $dest"
cd "$( dirname $( dirname $0 ) )"

rsync \
    -vrlpt \
    --delete \
    --delete-excluded \
    --exclude-from=.pubignore \
    -e ssh \
    . "$dest"

