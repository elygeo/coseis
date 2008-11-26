#!/usr/bin/env python
import glob, numpy, pylab, sord

normalize = 0
np = []
tt = []

for dir in glob.glob( '[0-9]*' ):
    prm = sord.util.load( dir + '/parameters.py' )
    np += [ numpy.product( prm['np3'] ) ]
    t = numpy.fromfile( dir + '/prof/8step', numpy.float32 )
    tt += [ numpy.sum( t[1:-1] ) / (len(t)-2) ]

if normalize:
    tt = [ t / tt[0] for t in tt ]

print 'time cores'
for n, t in zip( np, tt ):
    print '%4.2f %d' % (t, n)

cfg = sord.util.load( dir + '/conf.py' )
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
    pylab.ylabel( 'Time per step (s)' )
    pylab.axis([-1, n, 0, 2*int(numpy.average(tt)+0.5) ])
pylab.draw()
pylab.savefig( 'bench.pdf', format='pdf' )
pylab.show()

