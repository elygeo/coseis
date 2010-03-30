#!/bin/bash -e
# Install statically-linked Python and Numpy
# for Cray Compute Node Linux (CNS) on NICS Kraken.
# Made possible by the instructions found at these sites:
# https://wiki.fysik.dtu.dk/gpaw/install/Cray/louhi.html
# http://yt.enzotools.org/wiki/CrayXT5Installation
# http://code.google.com/p/pyprop/wiki/Installation_CrayXT4

# location
prefix="/lustre/scratch/${USER}/local"

# confirm
echo "Installing in ${prefix}."
echo -n "Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# environment
module swap PrgEnv-pgi PrgEnv-gnu
export PATH="${prefix}/bin:${PATH}"
export PYTHONPATH="${prefix}/lib/python2.6/site-packages/"
export CC=cc
export CXX=CC
export FC=ftn
export F77=f77
export OPT='-O'

# copy patch files
mkdir -p "${prefix}"
cp python-cnl-*.patch "${prefix}"

# Install Python
ver_python="2.6.2"
ver_python="2.6.5"
cd "${prefix}"
curl "http://www.python.org/ftp/python/${ver_python}/Python-${ver_python}.tgz" | tar zxv
cd "Python-${ver_python}"
patch -p1 < "../python-cnl-1.patch"
./configure --prefix="${prefix}" SO=.a DYNLOADFILE=dynload_cnl.o MACHDEP=cnl --host=x86_64-unknown-linux-gnu --disable-sockets --disable-ssl --enable-static --disable-shared
patch -p1 < "../python-cnl-2.patch"
make
make install

# Install Numpy
ver_numpy="1.2.1" # ver 1.3.0 fails for libnpymath
cd "${prefix}"
curl "http://superb-west.dl.sourceforge.net/sourceforge/numpy/numpy-${ver_numpy}.tar.gz" | tar zxv
cd "numpy-${ver_numpy}"
#python setup.py build
python setup.py install --prefix="${prefix}"
cd "../Python-${ver_python}"
patch -p1 < "../python-cnl-3.patch"
make
make install

