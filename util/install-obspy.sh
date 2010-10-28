#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# ObsPy
cd "${prefix}"
svn checkout https://svn.geophysik.uni-muenchen.de/svn/obspy obspy
cd obspy/misc/scripts
bash develop.sh

cd "${pwd}"

