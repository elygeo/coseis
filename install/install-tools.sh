#!/bin/bash -e
prefix="${1:-${HOME}/local}"

# Python tools
.   install-python.sh "${prefix}"
.   install-zlib.sh "${prefix}"
.   install-numpy.sh "${prefix}"
.   install-vtk.sh "${prefix}"
.   install-wxpython.sh "${prefix}"
pip install virtualenv
pip install docutils
pip install ipython
pip install cython
pip install bzr
pip install nose
pip install configobj
pip install pypdf
pip install PIL				# dep: zlib
pip install pyproj			# dep: numpy
pip install matplotlib			# dep: numpy, wxpython, configobj
pip install 'Mayavi[app]'r		# dep: numpy, wxpython, configobj, vtk
.   install-obspy.sh "${prefix}"	# dep: matplotlib

#pip install scipy			# dep: numpy
#http://downloads.sourceforge.net/project/scipy/scipy/0.8.0rc1/scipy-0.8.0rc1-py2.6-python.org.dmg
pip install http://downloads.sourceforge.net/project/scipy/scipy/0.8.0rc1/scipy-0.8.0rc1.tar.gz

