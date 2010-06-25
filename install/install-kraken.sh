#!/bin/bash -e
# Install Python for NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation
# http://yt.enzotools.org/wiki/CrayXT5Installation
# https://wiki.fysik.dtu.dk/gpaw/install/Cray/louhi.html
# http://code.google.com/p/pyprop/wiki/Installation_CrayXT4

# install location
prefix="${1:-${HOME}/local}"

# yt python vertion
url='http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.4.9.tar.gz'
url='http://bitbucket.org/ianb/virtualenv/get/tip.gz#egg=virtualenv-tip'
cd "${prefix}"
curl "${url}" | tar zx
/lustre/scratch/proj/yt_common/trunk/bin/python virtualenv/virtualenv.py yt
. yt/bin/activate

# Coseis path
cd "${HOME}/coseis"
python setup.py path

