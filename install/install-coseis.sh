#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Bazaar version control
easy_install bzr

# Coseismic
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/coseismic
mkdir -p bin
cd bin
ln -s ../sord/util/swab.py .
ln -s ../sord/util/stats.py .

