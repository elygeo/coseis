#!/usr/bin/env ipython -pylab -wthread
import os, numpy, pylab, sord, sim

slice = (), sim.nn[1]/2, ()
slice = sim.nn[0]/2, (), ()
slice = (), (), 1

nn = sim.nn
path = os.path.expanduser( '~/run/tmp/z3' )

nn = [ n-1 for n in sim.nn ]
path = os.path.expanduser( '~/run/cvm4/dep' )

v = sord.util.ndread( path, nn, slice ).squeeze()

fig = pylab.gcf()
fig.clf()
ax = fig.add_subplot( 111 )
im = ax.imshow( v.T, interpolation='nearest' )
fig.colorbar( im, orientation='horizontal' )
ax.axis( 'image' )
fig.canvas.draw()
fig.show()

