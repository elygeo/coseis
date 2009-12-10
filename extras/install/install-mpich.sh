#!/bin/bash -e
# Install MPICH2

# Set version and loction here:
version="1.2.1"
path="${HOME}/local"

link="http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/${version}/mpich2-${version}.tar.gz"

prefix="$( eval echo ${path} )"
echo -n "Installing MPICH2 ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

curl "${link}" | tar zxv
cd "mpich2-${version}"
./configure -prefix="${prefix}" --with-device=ch3:shm
make
make install

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/bin:\${PATH}\""

