#!/bin/bash -e

# set location here:
path="\${HOME}/local"
prefix="$( eval echo ${path} )"

# confirm
echo -n "Installing in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# MPICH2
version="1.2.1p1"
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

# PATH
export PATH="${prefix}/bin:${PATH}"
echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/bin:\${PATH}\""

