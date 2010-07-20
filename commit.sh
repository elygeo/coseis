#!/bin/bash -e

cd $( dirname $0 )

version="3.2.$(( $( bzr revno ) + 1 ))"
echo "$version" > version

bzr commit -m "$1"
bzr export "download/coseis.tgz"

