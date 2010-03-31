#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

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

