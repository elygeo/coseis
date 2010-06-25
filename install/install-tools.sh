#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Virtualenv
easy_install virtualenv

# PIP
easy_install pip

# Docutils
easy_install docutils

# Ipython
easy_install ipython

# zlib
url="http://www.zlib.net/zlib-1.2.5.tar.gz"
curl "${url}" | tar zx
cd zlib-1.2.5
./configure --prefix="${prefix}"
make install
./configure --prefix="${prefix}" --shared
make install

# Python Imaging Library
easy_install PIL

# PyPDF
easy_install pypdf

# Visualization Toolkit
. install-vtk.sh "${prefix}"

# wxPython
. install-wxpython.sh "${prefix}"

# Matplotlib, dependencies: wxPython
easy_install matplotlib

# SciPy
easy_install scipy

# Mayavi, dependencies: vtk, wxpython, configobj
easy_install configobj
easy_install 'Mayavi[app]'r

# ObsPy, dependencies: matplotlib
. install-obspy.sh "${prefix}"

