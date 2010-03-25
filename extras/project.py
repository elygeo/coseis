#!/usr/bin/env python
# Projection utility for lon/lat to UTM coodinates.
# File format is ASCII text separated by white space, one point per line.
# The origin is set by lon0, lat0. UTM coordinates are rotated slightly
# to exactly align the x-axis to East-West at the origin.
# USAGE
#     project.py infile outfile
# OPTIONS
#     -i inverse projection, (x, y) to (lon, lat)
# REQUIREMENTS
#     Python with Numpy and Pyproj packages
#     Numpy and Pyproj can be installed by:
#     $ curl -O http://peak.telecommunity.com/dist/ez_setup.py
#     $ python ez_setup.py
#     $ easy_install numpy pyproj

lon0, lat0 = -123.15, 36.35

import sys, pyproj
import numpy as np

try:
    import coord
except ImportError:
    import urllib
    print 'Downloading coord.py.'
    url = 'http://earth.usc.edu/~gely/cvm/extras/coord.py'
    urllib.urlretrieve( url, 'coord.py' )
    import coord

argv = sys.argv[1:]
inverse = '-i' in argv
infile = argv[-2]
outfile = argv[-1]

origin = (lon0-0.1, lon0+0.1), (lat0, lat0)
proj = pyproj.Proj( proj='utm', zone=11 )
proj = coord.Transform( proj, origin=origin )

data = np.loadtxt( infile, unpack=True )
data[:2] = proj( data[0], data[1], inverse=inverse )
np.savetxt( outfile, data.T )

