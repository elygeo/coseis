#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# MPICH2
url="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.2.1p1/mpich2-1.2.1p1.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
#if [ "${MACHTYPE}" = 'x86_64-apple-darwin10.0' ]; then
#    ./configure -prefix="${prefix}" --with-device=ch3:shm CFLAGS='-arch x86_64' CXXFLAGS='-arch x86_64' FFLAGS='-arch x86_64' F90FLAGS='-arch x86_64'
#else
#    ./configure -prefix="${prefix}" --with-device=ch3:shm
#fi
./configure -prefix="${prefix}" --with-device=ch3:shm
make
make install
export PATH="${prefix}/bin:${PATH}"

cd "${pwd}"

