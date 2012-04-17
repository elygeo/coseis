#!/bin/bash -e
prefix="${HOME}/local"
echo -n "Install NumPy in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# NumPy
cd "${prefix}"
url='http://downloads.sourceforge.net/project/numpy/NumPy/1.6.1/numpy-1.6.1.tar.gz'
tag=$( basename "$url" .tar.gz )
curl -L "${url}" | tar zx
cd "${tag}"
python setup.py install

