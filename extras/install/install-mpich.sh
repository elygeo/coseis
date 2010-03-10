#!/bin/bash -e
# Install MPICH2

# Set version and loction here:
version="1.2.1p1"
path="\${HOME}/local2"

prefix="$( eval echo ${path} )/mpich2-${version}"
echo -n "Installing MPICH2 ${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

curl "http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/${version}/mpich2-${version}.tar.gz" | tar zxv
cd "mpich2-${version}"
if [ "${MACHTYPE}" = 'x86_64-apple-darwin10.0' ]; then
    ./configure -prefix="${prefix}" --with-device=ch3:shm --enable-f90 CFLAGS='-arch x86_64' CXXFLAGS='-arch x86_64' FFLAGS='-arch x86_64' F90FLAGS='-arch x86_64'
else
    ./configure -prefix="${prefix}" --with-device=ch3:shm --enable-f90
fi
make
make install

eval cd "${path}"
[ -e mpich2 ] || ln -s "$( basename ${prefix} )" mpich2

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/mpich2/bin:\${PATH}\""

