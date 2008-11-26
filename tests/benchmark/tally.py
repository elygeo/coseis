#!/usr/bin/env python
import os, numpy, pylab, sord

np = []
tt = []
for d in os.listdir( '.' ):
    f = d + '/parameters.py'
    prm = sord.util.load( f )
    np += [ numpy.product( prm['np3'] ) ]
    f = d + '/prof/8step'
    t = numpy.fromfile( f, numpy.float32 )
    tt += [ numpy.sum( t[1:-1] ) / (len(t)-2) ]

tt = [ t / tt[0] for t in tt ]
print 'time cores'
for n, t in zip( np, tt ):
    print '%4.2f %d' % (t, n)

n = len( tt )
pylab.plot( tt, 'ko-' )
pylab.hold( True )
pylab.plot( [-1, n], [tt[0],tt[0]], 'k--' )
pylab.gca().set_xticks( range(n) )
pylab.gca().set_xticklabels( np )
pylab.axis([-1, n, 0, 16])
#pylab.ylabel( 'Time per step (s)' )
pylab.ylabel( 'Normalize run time' )
pylab.xlabel( 'Cores' )
pylab.title( 'SORD weak scaling benchmark - TACC Ranger' )
pylab.draw()
pylab.savefig( 'bench.pdf', format='pdf' )
pylab.show()

