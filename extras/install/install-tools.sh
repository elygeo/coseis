#!/bin/bash -e

# set location here:
path="\${HOME}/local"
prefix="$( eval echo ${path} )"

# confirm
echo -n "Installing in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# PyPI packages
easy_install numpy
easy_install pyproj
easy_install cython
easy_install PIL
easy_install wxpython
easy_install matplotlib
easy_install configobj
easy_install 'Mayavi[app]'
easy_install scipy
easy_install pypdf
easy_install bzr

# ObsPy
cd "${prefix}"
if [ ! -d obspy ]; then
    svn checkout https://svn.geophysik.uni-muenchen.de/svn/obspy obspy
    cd obspy/obspy/branches/scripts
    bash develop.sh
fi

# SCEC CVM4
if [ ! -d cvm ]; then
    bzr get http://earth.usc.edu/~gely/cvm
    cd cvm
    curl -O http://earth.usc.edu/~gely/cvm/cvm3-data.tgz
    curl -O http://earth.usc.edu/~gely/cvm/cvm4-data.tgz
fi

# SORD
cd "${prefix}"
if [ ! -d sord ]; then
    bzr get http://earth.usc.edu/~gely/sord
fi

