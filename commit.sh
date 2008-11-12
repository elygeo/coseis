#!/bin/bash -e
version="3.0.$(( $( bzr revno ) + 1 ))"
echo "$version" > version
./setup.py docs
bzr commit -m "version $version"
bzr export sord.tgz

