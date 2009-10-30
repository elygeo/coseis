#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, glob, numpy, sord

normalize = 0
np = []
tt = []

for d in glob.glob( '[0-9]*' ):
    prm = {}
    path = os.path.join( d, 'parameters.py' )
    exec open( path ) in prm
    np += [ numpy.product( prm['np3'] ) ]
    t = numpy.fromfile( d + '/prof/8step', 'f' )
    tt += [ numpy.sum( t[1:-1] ) / (len(t)-2) ]

if normalize:
    tt = [ t / tt[0] for t in tt ]

print 'time cores'
for n, t in zip( np, tt ):
    print '%4.2f %d' % (t, n)

if 0:
    import pylab
    cfg = {}
    path = os.path.join( d, 'conf.py' )
    exec open( path ) in cfg
    n = len( tt )
    pylab.plot( tt, 'ko-' )
    pylab.hold( True )
    pylab.plot( [-1, n], [tt[0],tt[0]], 'k--' )
    pylab.gca().set_xticks( range(n) )
    pylab.gca().set_xticklabels( np )
    #pylab.title( 'SORD weak scaling benchmark - ' + cfg['machine'] )
    pylab.title( 'SORD weak scaling benchmark - TACC Ranger' )
    pylab.xlabel( 'Cores' )
    if normalize:
        pylab.ylabel( 'Normalized run time' )
        pylab.axis([-1, n, 0, 4])
    else:
        pylab.ylabel( 'Time/step (s)' )
        pylab.axis([-1, n, 0, 2*int(numpy.average(tt)+0.5) ])
    pylab.draw()
    pylab.savefig( 'bench.pdf', format='pdf' )
    #pylab.show()

