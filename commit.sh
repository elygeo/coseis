#!/bin/bash -e

cd $( dirname $0 )

version="3.1.$(( $( bzr revno ) + 1 ))"

echo "$version" > version

bzr commit -m "$*"
bzr export "sord.tgz"

