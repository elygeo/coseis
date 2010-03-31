#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# MPICH2
url="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.2.1p1/mpich2-1.2.1p1.tar.gz"
dir=$( basename "$url" .tar.gz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${dir}"
if [ "${MACHTYPE}" = 'x86_64-apple-darwin10.0' ]; then
    ./configure -prefix="${prefix}" --with-device=ch3:shm --enable-f90 CFLAGS='-arch x86_64' CXXFLAGS='-arch x86_64' FFLAGS='-arch x86_64' F90FLAGS='-arch x86_64'
else
    ./configure -prefix="${prefix}" --with-device=ch3:shm --enable-f90
fi
make
make install
export PATH="${prefix}/bin:${PATH}"

