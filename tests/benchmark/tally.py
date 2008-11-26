#!/usr/bin/env python
import numpy, sord, os

dir = 'run/'
np = []
tt = []
for d in os.listdir( dir ):
    f = dir + d + '/parameters.py'
    p = sord.util.load( f )
    np += [ numpy.product( p['np3'] ) ]
    f = dir + d + '/prof/8step'
    t = numpy.fromfile( f, numpy.float32 )
    tt += [ numpy.sum( t[1:15] ) / 6 ]

pp = [ numpy.log2(p) for p in np ]
tt = [ t / tt[0] for t in tt ]
print 'time cores'
for n, t in zip( np, tt ):
    print '%4.2f %d' % (t, n)

