#!/bin/bash -e
# Install statically linked Python for Compute Node Linux on NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation

# install location
prefix="${1:-${SCRATCHDIR}/cnl}"

# yt python vertion
url='http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.4.9.tar.gz'
url='http://bitbucket.org/ianb/virtualenv/get/tip.gz#egg=virtualenv-tip'
cd "${prefix}"
curl "${url}" | tar zx
/lustre/scratch/proj/yt_common/trunk/bin/python virtualenv/virtualenv.py .
. bin/activate

# Coseis path
cd "${HOME}/coseis"
python setup.py path

