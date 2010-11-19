#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# MPICH2
url="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.3.1/mpich2-1.3.1.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure -prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

cd "${pwd}"

