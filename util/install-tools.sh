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
pip install virtualenv
pip install docutils
pip install ipython
pip install cython
pip install GitPython
pip install nose
pip install configobj
pip install pypdf
pip install PIL				# dep: zlib
pip install pyproj			# dep: numpy
pip install matplotlib			# dep: numpy, wxpython, configobj
pip install 'Mayavi[app]'r		# dep: numpy, wxpython, configobj, vtk
.   install-obspy.sh "${prefix}"	# dep: matplotlib

#pip install scipy			# dep: numpy
#pip install http://downloads.sourceforge.net/project/scipy/scipy/0.8.0/scipy-0.8.0.tar.gz

