#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Bazaar version control
easy_install bzr

# Coseismic
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/coseis
cd coseis
python setup.py all
mkdir -p bin
cd bin
ln -s ../tools/swab.py .
ln -s ../tools/stats.py .

