#!/bin/bash -e

cd $( dirname $0 )
bzr shelve
bzr version-info > version
bzr add version
bzr commit -m temp
bzr export "download/coseis.tgz"
bzr uncommit
bzr rm --force version
bzr unshelve

