#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"
echo -n "Install Python in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# Python
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Max OS X
url='http://www.python.org/ftp/python/2.7.2/python-2.7.2-macosx10.6.dmg'
tag=$( basename "$url" )
cd "${prefix}"
curl -LO "${url}"
hdid "${tag}"
installer -pkg '/Volumes/Python 2.7.2/Python.mpkg' -target '/'
export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

else

# Linux
url='http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz'
tag=$( basename "$url" .tgz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

fi

