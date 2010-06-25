#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# zlib
url="http://www.zlib.net/zlib-1.2.5.tar.gz"
curl "${url}" | tar zx
cd zlib-1.2.5
./configure --prefix="${prefix}"
make install
./configure --prefix="${prefix}" --shared
make install

pip install PIL				# dep: zlib
pip install pypdf
pip install scipy
.   install-wxpython.sh "${prefix}"
pip install matplotlib			# dep: wxpython
.   install-obspy.sh "${prefix}"	# dep: matplotlib
.   install-vtk.sh "${prefix}"
pip install configobj
pip install 'Mayavi[app]'r		# dep: wxpython, configobj, vtk

