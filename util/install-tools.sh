#!/bin/bash -e
prefix="${1:-${HOME}/local}"

# Tools
.   install-python.sh "${prefix}"
.   install-git.sh "${prefix}"
.   install-numpy.sh "${prefix}"
.   install-zlib.sh "${prefix}"
.   install-jpeg.sh "${prefix}"
.   install-mpich.sh "${prefix}"	# dep: python?
.   install-vtk.sh "${prefix}"		# dep: python < 2.7
.   install-wxpython.sh "${prefix}"	# dep: vtk
pip install virtualenv			# not in EPD
pip install docutils
pip install ipython
pip install cython
pip install GitPython			# not in EPD
pip install nose
pip install configobj
pip install pypdf			# not in EPD
pip install web.py			# not in EPD
pip install PIL				# dep: zlib
pip install pyproj			# dep: numpy
pip install scipy			# dep: numpy
pip install 'Mayavi[app]'r		# dep: numpy, wxpython, configobj, vtk
#pip install matplotlib			# dep: numpy, wxpython, configobj
pip install "http://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.0/matplotlib-1.0.0.tar.gz"
.   install-obspy.sh "${prefix}"	# dep: matplotlib, not in EPD

