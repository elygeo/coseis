#!/bin/bash -e

cd "$( dirname $( dirname $0 ) )/download"
bzr export coseis.tar
mkdir coseis
bzr version-info > coseis/version
tar -rf coseis.tar coseis/version
gzip -c coseis.tar > coseis.tgz
rm -r coseis.tar coseis

