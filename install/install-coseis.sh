#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Bazaar version control
easy_install pip
pip install bzr

# Coseismic
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/coseis
cd coseis
python setup.py path build

