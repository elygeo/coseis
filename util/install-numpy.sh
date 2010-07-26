#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# NumPy
url='http://downloads.sourceforge.net/project/numpy/NumPy/1.4.1/numpy-1.4.1.tar.gz'
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
python setup.py install

cd "${pwd}"

