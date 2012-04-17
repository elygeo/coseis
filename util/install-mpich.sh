#!/bin/bash -e
prefix="${HOME}/local"
echo -n "Install MPICH2 in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# MPICH2
cd "${prefix}"
url="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.4.1p1/mpich2-1.4.1p1.tar.gz"
tag=$( basename "$url" .tar.gz )
curl -L "${url}" | tar zx
cd "${tag}"
./configure -prefix="${prefix}"
make
make install

