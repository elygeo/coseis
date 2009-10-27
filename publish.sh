#!/bin/bash

dest="earth.usc.edu:public_html/sord"
echo "syncing to $dest"
cd $( dirname $0 )

rsync -avR --delete --delete-excluded --include=sord.tgz --include=.bzr --exclude-from=.ignore -e ssh . "$dest"

