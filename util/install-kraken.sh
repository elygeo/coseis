#!/bin/bash -e
# Install statically linked Python for Compute Node Linux on NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation

pwd="${PWD}"
cd "${SCRATCHDIR}"

# yt python vertion
virtualenv --python=/lustre/scratch/proj/yt_common/trunk/bin/python local
. local/bin/activate
pip install pyproj

# Coseis
cd coseis
python setup.py path

cd "${pwd}"

