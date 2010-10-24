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
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='*.pyc' \
    --exclude='*.so' \
    --exclude='run' \
    --exclude='tmp' \
    --exclude='build' \
    --exclude='/data' \
    --exclude='/cst/conf/site.py' \
    -e ssh \
    . "$dest"

