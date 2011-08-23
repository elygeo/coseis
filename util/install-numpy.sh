#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"

# NumPy
url='http://downloads.sourceforge.net/project/numpy/NumPy/1.6.1/numpy-1.6.1.tar.gz'
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
python setup.py install

cd "${pwd}"

