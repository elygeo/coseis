#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# ObsPy
cd "${prefix}"
svn checkout https://svn.geophysik.uni-muenchen.de/svn/obspy obspy
cd obspy/obspy/branches/scripts
bash develop.sh

