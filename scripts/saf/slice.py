#!/usr/bin/env ipython -pylab -wthread
import os, numpy, pylab, sord, sim

slice = sim.nn[0]/2, (), ()
slice = (), (), 1
slice = (), sim.nn[1]/2, ()

dir = sim.rundir
dir = sim.indir_
nn = sim.nn
nc = [ n-1 for n in sim.nn ]
vs = sord.util.ndread( os.path.join( dir, 'vs' ), nc, slice ).squeeze()
i = [ i for i in range( len( slice ) ) if slice[i] != () ][0]

if i == 2:
    xx = sord.util.ndread( os.path.join( dir, 'x' ), nn[:2] )
    yy = sord.util.ndread( os.path.join( dir, 'y' ), nn[:2] )
else:
    x = numpy.arange( sim.nn[1-i] ) * sim.dx[1-i]
    y = numpy.arange( sim.nn[2] ) * sim.dx[2]
    yy, xx = numpy.meshgrid( y, x )
    yy = sord.util.ndread( os.path.join( dir, 'z3' ), nn, slice ).squeeze()

pylab.clf()
pylab.pcolor( xx, yy, vs, edgecolor='k' )
pylab.axis( 'image' )
pylab.show()
pylab.draw()

