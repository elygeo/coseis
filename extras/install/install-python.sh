#!/bin/bash -e
# Install Python, setuptools, Numpy and Pyproj.

# Set version and location here:
version="2.6.4"
path="\${HOME}/local"

prefix="$( eval echo ${path} )/python-${version}"
echo -n "Installing Python-${version} and setuptools in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"
cd "${prefix}"

curl "http://www.python.org/ftp/python/${version}/Python-${version}.tgz" | tar zx
cd "Python-${version}"
./configure --prefix="${prefix}"
make
make install

export PATH="${prefix}/bin:${PATH}"
curl -O http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"

eval cd "${path}"
[ -e python ] || ln -s "$( basename ${prefix} )" python

easy_install cython
easy_install numpy
easy_install pyproj
#easy_install wxpython
easy_install matplotlib
easy_install scipy
easy_install bzr

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

