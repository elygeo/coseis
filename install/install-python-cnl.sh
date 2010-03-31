#!/bin/bash -e
# Install statically-linked Python and Numpy
# for Cray Compute Node Linux (CNS) on NICS Kraken.
# Made possible by the instructions found at these sites:
# https://wiki.fysik.dtu.dk/gpaw/install/Cray/louhi.html
# http://yt.enzotools.org/wiki/CrayXT5Installation
# http://code.google.com/p/pyprop/wiki/Installation_CrayXT4

# location
prefix="/lustre/scratch/${USER}/local"
mkdir -p "${prefix}"
cp python-cnl-*.patch "${prefix}"

# environment
module swap PrgEnv-pgi PrgEnv-gnu
export PATH="${prefix}/bin:${PATH}"
export PYTHONPATH="${prefix}/lib/python2.6/site-packages/"
export CC=cc
export CXX=CC
export FC=ftn
export F77=f77
export OPT='-O'

# Python
url="http://www.python.org/ftp/python/2.6.5/Python-2.6.5.tgz"
url="http://www.python.org/ftp/python/2.6.5/Python-2.6.2.tgz"
dir=$( basename "${url}" .tgz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${dir}"
patch -p1 < "../python-cnl-1.patch"
./configure --prefix="${prefix}" SO=.a DYNLOADFILE=dynload_cnl.o MACHDEP=cnl --host=x86_64-unknown-linux-gnu --disable-sockets --disable-ssl --enable-static --disable-shared
patch -p1 < "../python-cnl-2.patch"
make
make install

# Numpy version 1.3.0 fails for libnpymath, so use version 1.2.1
url="http://superb-west.dl.sourceforge.net/sourceforge/numpy/numpy-1.2.1.tar.gz"
ver=$( basename "${url}" .tar.gz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${ver}"
python setup.py install --prefix="${prefix}"
cd "${prefix}/${dir}"
patch -p1 < "../python-cnl-3.patch"
make
make install

