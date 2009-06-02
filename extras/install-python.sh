#!/bin/bash -e
# This script installs official Python.
# For more bells and whistles, the Enthought Python Distribution is highly recommended

version="2.6.2"
prefix="${HOME}/local"

echo -n "Installing Python-${version} and setuptools in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

export PATH="${prefix}/bin:${PATH}"
mkdir -p "${prefix}"
cd "${prefix}"

wget "http://www.python.org/ftp/python/${version}/Python-${version}.tgz"
tar zxvf "Python-${version}.tgz"
cd "Python-${version}"
./configure --prefix="${prefix}"
make
make install

wget http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py --prefix="${prefix}"

easy_install numpy
easy_install pyproj

echo "Don't forget to add \${prefix}/bin to your path"

