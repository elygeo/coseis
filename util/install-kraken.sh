#!/bin/bash -e
# Install statically linked Python for Compute Node Linux on NICS Kraken
# http://yt.enzotools.org/wiki/KrakenCommunityInstallation

module swap PrgEnv-pgi PrgEnv-gnu
module load git vim

pwd="${PWD}"
cd "${SCRATCHDIR}"

# yt python vertion
virtualenv --python=/lustre/scratch/proj/yt_common/2.0/bin/python local
. local/bin/activate
pip install pyproj

# Coseis
git clone git@github.com:gely/coseis.git
cd coseis
python setup.py path
python setup.py --machine=nics-kraken
python setup.py build

cd "${pwd}"

