#!/bin/bash -e
# Install Python, setuptools, Numpy and Pyproj.

version="2.6.4"
prefix="${HOME}/local/python"

echo -n "Installing Python-${version} and setuptools in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH="${prefix}/bin:${PATH}"
mkdir -p "${prefix}"
cd "${prefix}"

curl "http://www.python.org/ftp/python/${version}/Python-${version}.tgz" | tar zx
cd "Python-${version}"
./configure --prefix="${prefix}"
make
make install

curl -O http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"

easy_install numpy
easy_install pyproj

echo "Don't forget to add \${prefix}/bin to your path"

