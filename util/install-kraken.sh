#!/bin/bash -e
prefix="${1:-${SCRATCHDIR}/local}"
pwd="${PWD}"

# Install statically linked Python for Compute Node Linux on NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation

# yt python vertion
url='http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.5.1.tar.gz'
url='http://bitbucket.org/ianb/virtualenv/get/tip.gz#egg=virtualenv-tip'
cd "${prefix}"
curl -L "${url}" | tar zx
/lustre/scratch/proj/yt_common/trunk/bin/python virtualenv/virtualenv.py .
. bin/activate

# Coseis path
cd "${HOME}/coseis"
python setup.py path

#pip install pyproj

cd "${pwd}"

