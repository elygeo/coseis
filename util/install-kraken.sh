#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"
echo "Statically linked Python for Compute Node Linux on NICS Kraken"
echo "See: http://yt.enzotools.org/wiki/KrakenCommunityInstallation"
echo -n "Install in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# virtualenv
url="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.6.1.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx

# yt python version
module load yt
cd "${SCRATCHDIR}"
python "${prefix}/local/${tag}/virtualenv.py" local
. local/bin/activate
pip install pyproj
pip install GitPython
pip install readline
pip install nose
pip install docutils
pip install PIL
#pip install scipy
#pip install ipython

# Coseis
cd coseis
python setup.py path

cd "${pwd}"

