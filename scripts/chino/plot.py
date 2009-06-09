#!/usr/bin/env ipython -pylab -wthread
"""
Mesh plot
"""
import numpy, pylab, sord, sim

nn = sim.nn
slice = (), nn[1]/2, ()
slice = (), (), 1
slice = nn[0]/2, (), ()

x = numpy.arange( sim.nn[0] ) * sim.dx[0]
y = numpy.arange( sim.nn[1] ) * sim.dx[1]
z = numpy.arange( sim.nn[2] ) * sim.dx[2]
nc = [ n-1 for n in sim.nn ]

zz, xx = numpy.meshgrid( z, x )
zz, yy = numpy.meshgrid( z, y )
zz = sord.util.ndread( 'z3', nn, slice ).squeeze()
vs = sord.util.ndread( 'vs', nc, slice ).squeeze()

pylab.clf()

if slice[0] != ():
    pylab.pcolor( yy, zz, vs, edgecolor='k' )
elif slice[1] != ():
    pylab.pcolor( xx, zz, vs, edgecolor='k' )
else:
    yy, xx = numpy.meshgrid( y, x )
    pylab.pcolor( xx, yy, vs, edgecolor='k' )

pylab.axis( 'image' )
pylab.show()
pylab.draw()

