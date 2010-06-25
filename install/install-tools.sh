#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Misc tools
easy_install pip
pip install bzr
pip install virtualenv
pip install docutils
pip install ipython
pip install pypdf

# zlib and Python Imaging Library
url="http://www.zlib.net/zlib-1.2.5.tar.gz"
curl "${url}" | tar zx
cd zlib-1.2.5
./configure --prefix="${prefix}"
make install
./configure --prefix="${prefix}" --shared
make install
pip install PIL

# Visualization Toolkit
. install-vtk.sh "${prefix}"

# wxPython
. install-wxpython.sh "${prefix}"

# Matplotlib, dependencies: wxPython
pip install matplotlib

# SciPy
pip install scipy

# Mayavi, dependencies: vtk, wxpython, configobj
pip install configobj
pip install 'Mayavi[app]'r

# ObsPy, dependencies: matplotlib
. install-obspy.sh "${prefix}"

