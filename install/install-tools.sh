#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# Visualization Toolkit
. install-vtk.sh "${prefix}"

# wxPython
. install-wxpython.sh "${prefix}"

# Python Imaging Library
easy_install PIL

# PyPDF
easy_install pypdf

# Matplotlib, dependencies: wxPython
easy_install matplotlib

# Mayavi, dependencies: vtk, wxpython, configobj
easy_install configobj
easy_install 'Mayavi[app]'r

# SciPy
easy_install scipy

# ObsPy, dependencies: matplotlib
. install-obspy.sh "${prefix}"

