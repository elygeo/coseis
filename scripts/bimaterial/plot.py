#!/usr/bin/env python
"""
Bimaterial problem
"""
import sord, pylab

n = 401, 200
sl = numpy.fromfile( '~/run/bimat/out/slip', 'f' ).reshape( n[::-1] ).T
pylab.plot( sl[:,::20] )
pylab.show()

