#!/bin/bash -e

prefix="${HOME}/local"

# Python
url="http://www.python.org/ftp/python/2.6.5/Python-2.6.5.tgz"
dir=$( basename "$url" .tgz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${dir}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

# setuptools
curl -O http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"

# distribute may eventually replace setuptools
#curl -O http://python-distribute.org/distribute_setup.py
#python distribute_setup.py --prefix="${prefix}"

# PyPI packages
easy_install cython
easy_install numpy
easy_install bzr
easy_install pyproj

# SORD
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/sord
cd sord
python setup path

# SCEC CVM4
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/cvm
cd cvm
curl -O http://earth.usc.edu/~gely/cvm/cvm3-data.tgz
curl -O http://earth.usc.edu/~gely/cvm/cvm4-data.tgz

