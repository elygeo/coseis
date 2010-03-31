#!/bin/bash -e

prefix="${HOME}/local"

# Misc
easy_install bzr
easy_install pypdf
bash install-obspy.sh

# SORD
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/sord
cd sord
python setup path

# SCEC CVM4
cd "${prefix}"
bzr get http://earth.usc.edu/~gely/cvm
cd cvm
curl -O http://earth.usc.edu/~gely/cvm/cvm3-data.tgz
curl -O http://earth.usc.edu/~gely/cvm/cvm4-data.tgz

