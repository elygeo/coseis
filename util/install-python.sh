#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# Python
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Max OS X
url='http://www.python.org/ftp/python/2.7/python-2.7-macosx10.5.dmg'
tag=$( basename "$url" )
cd "${prefix}"
curl -LO "${url}"
hdid "${tag}"
installer -pkg '/Volumes/Python 2.7/Python.mpkg' -target '/'
export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

else

# Linux
url='http://www.python.org/ftp/python/2.7/Python-2.7.tgz'
tag=$( basename "$url" .tgz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/bin:${PATH}"

fi

# package managers: Distribute and PIP
cd "${prefix}"
curl -LO http://python-distribute.org/distribute_setup.py
python distribute_setup.py
easy_install pip

cd "${pwd}"

