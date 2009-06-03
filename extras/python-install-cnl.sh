#!/bin/bash -e
# This script installs statically linked Python.
# Needed for Cray Compute Node Linux (CNS) on NICS Kraken.
# http://code.google.com/p/pyprop/wiki/Installation_CrayXT4
# http://yt.enzotools.org/wiki/CrayXT5Installation
# https://wiki.fysik.dtu.dk/gpaw/install/Cray/louhi.html

ver_python="2.6.2"
ver_numpy="1.3.0"
prefix="${HOME}/local"
prefix="/lustre/scratch/${USER}/local"

echo -n "Installing Python-${ver_python} and setuptools in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Set environment
module swap PrgEnv-pgi PrgEnv-gnu
export PATH="${prefix}/bin:${PATH}"
export PYTHONPATH="${prefix}/lib/python2.6/site-packages/"
export CC=cc
export CXX=CC
export FC=ftn
export F77=f77
export OPT='-O'

# Fetch files
mkdir -p "${prefix}"
cp python-cnl.patch "${prefix}"
cd "${prefix}"
wget "http://www.python.org/ftp/python/${ver_python}/Python-${ver_python}.tgz"
wget "http://superb-west.dl.sourceforge.net/sourceforge/numpy/numpy-${ver_numpy}.tar.gz"
tar zxvf "Python-${ver_python}.tgz"
tar zxvf "numpy-${ver_numpy}.tar.gz"

# Install Python
cd "Python-${ver_python}"
patch -p1 < ../python-cnl.patch
./configure --prefix="${prefix}" SO=.a DYNLOADFILE=dynload_cnl.o MACHDEP=cnl --host=x86_64-unknown-linux-gnu --disable-sockets --disable-ssl --enable-static --disable-shared
make install
#make bininstall
#make inclinstall
#make libainstall

# Install Numpy
cd "../numpy-${ver_numpy}"
python setup.py install >& "numpy.install.log"
cd "../Python-${ver_python}"
make install

echo "Don't forget to add \${prefix}/bin to your path"

