#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Python
url='http://www.python.org/ftp/python/2.6.5/Python-2.6.5.tgz'
tag=$( basename "$url" .tgz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

# Package managers: Distribute and PIP
curl -O http://python-distribute.org/distribute_setup.py
python distribute_setup.py --prefix="${prefix}"
easy_install pip

# NumPy
url='http://downloads.sourceforge.net/project/numpy/NumPy/1.4.1/numpy-1.4.1.tar.gz'
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
python setup install --prefix="${prefix}"

# PyPI packages
pip install virtualenv
pip install nose
pip install ipython
pip install docutils
pip install pyproj
pip install cython
pip install bzr

