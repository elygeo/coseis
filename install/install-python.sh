#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Python
url='http://www.python.org/ftp/python/2.6.5/Python-2.6.5.tgz'
dir=$( basename "$url" .tgz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${dir}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

# setuptools deprecated
#curl -O http://peak.telecommunity.com/dist/ez_setup.py
#python ez_setup.py --prefix="${prefix}"

# Distribute
curl -O http://python-distribute.org/distribute_setup.py
python distribute_setup.py --prefix="${prefix}"

# NumPy
#url='http://downloads.sourceforge.net/project/numpy/NumPy/1.4.1/numpy-1.4.1.tar.gz'
#dir=$( basename "$url" .tar.gz )
#cd "${prefix}"
#curl "${url}" | tar zx
#cd "${dir}"
#python setup install --prefix="${prefix}"

# PyPI packages
easy_install pip
pip install ipython
pip install docutils
pip install numpy
pip install pyproj
pip install cython
pip install scipy
pip install virtualenv
pip install bzr

