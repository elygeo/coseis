#!/usr/bin/env python
import numpy, pylab
n  = 61, 61
vx = numpy.fromfile( 'tmp/out/vx', 'f' ).reshape( n )
vy = numpy.fromfile( 'tmp/out/vy', 'f' ).reshape( n )
vm = numpy.sqrt( vx * vx + vy * vy )
pylab.figure( figsize=(3, 3) )
pylab.imshow( vm, extent=(-3, 3, -3, 3), interpolation='nearest', vmax=1 )
pylab.axis( 'image' )
pylab.savefig( 'tmp/example.png', dpi=80 )
