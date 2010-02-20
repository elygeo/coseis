#!/usr/bin/env python
import numpy, pylab
import matplotlin.pyplot as plt
n  = 61, 61
vx = numpy.fromfile( 'tmp/out/vx', 'f' ).reshape( n )
vy = numpy.fromfile( 'tmp/out/vy', 'f' ).reshape( n )
vm = numpy.sqrt( vx * vx + vy * vy )
fig = plt.figure( figsize=(3, 3) )
ax = fig.add_subplot( 111 )
ax.imshow( vm, extent=(-3, 3, -3, 3), interpolation='nearest', vmax=1 )
ax.axis( 'image' )
fig.savefig( 'tmp/example.png', dpi=80 )
