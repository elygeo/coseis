#!/usr/bin/env python
import numpy
from sord import util

dir = 'run'
np = []
tt = []
for i in range( 1, 8 ):
    f = dir + '/%02d/parameters.py' % i
    p = util.load( f )
    np += [ numpy.product( p['np'] ) ]
    f = dir + '/%02d/prof/step' % i
    t = numpy.fromfile( f, numpy.float32 )
    tt += [ numpy.sum( t[1:7] ) / 6 ]

pp = [ numpy.log2(p) for p in np ]
tt = [ t / tt[0] for t in tt ]
print 'time cores'
for n, t in zip( np, tt ):
    print '%4.2f %d' % (t, n)

