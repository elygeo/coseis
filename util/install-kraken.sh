#!/bin/bash -e
# Install statically linked Python for Compute Node Linux on NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation
pwd="${PWD}"

# virtualenv
cd
url="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.5.1.tar.gz"
tag=$( basename "$url" .tar.gz )
curl -L "${url}" | tar zx

# yt python version
cd "${SCRATCHDIR}"
"$HOME/$tag/virtualenv.py" --python=/lustre/scratch/proj/yt_common/trunk/bin/python local
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

