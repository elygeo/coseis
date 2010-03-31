#!/bin/bash -e

. install-vtk.sh
. install-wxpython.sh

easy_install PIL
easy_install pypdf
easy_install matplotlib
easy_install configobj
easy_install 'Mayavi[app]'
easy_install scipy

. install-obspy.sh

