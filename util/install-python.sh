#!/bin/bash -e
prefix="${HOME}/local"
echo -n "Install Python in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Python
cd "${prefix}"
url='http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz'
tag=$( basename "$url" .tgz )
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make install

