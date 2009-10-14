#!/bin/bash -e
# This script installs MPICH2

# Set loction here:
prefix="${HOME}/local"
prefix="/usr/local"

version="1.1.1p1"
link="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/${version}/mpich2-${version}.tar.gz"

echo -n "Installing MPICH2 ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

wget "${link}"
tar zxvf "mpich2-${version}.tar.gz"
cd "mpich2-${version}"
./configure -prefix="${prefix}" --with-device=ch3:shm
make
make install

export PATH="${prefix}/bin:${PATH}"
echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${prefix}/bin:\${PATH}\""
