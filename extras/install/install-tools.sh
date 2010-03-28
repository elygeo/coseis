#!/bin/bash -e
# Install simulation tools

# set location here:
path="\${HOME}/local"

# confirm
prefix="$( eval echo ${path} )"
echo -n "Installing simulation tools in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# PyPI packages
easy_install bzr
easy_install pypdf

# ObsPy
cd "${prefix}"
if [ ! -d obspy ]; then
    svn checkout https://svn.geophysik.uni-muenchen.de/svn/obspy obspy
    cd obspy/obspy/branches/scripts
    bash develop.sh
fi

# SORD
cd "${prefix}"
if [ ! -d sord ]; then
    bzr get http://earth.usc.edu/~gely/sord
fi

# SCEC CVM4
if [ ! -d cvm ]; then
    bzr get http://earth.usc.edu/~gely/cvm
    cd cvm
    curl -O http://earth.usc.edu/~gely/cvm/cvm3-data.tgz
    curl -O http://earth.usc.edu/~gely/cvm/cvm4-data.tgz
fi

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

