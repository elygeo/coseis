#!/usr/bin/env python
"""
TPV3
"""
import math, numpy, pylab, sord

bi_dir = '../../../bi/'
so_dir = ''
prm = sord.util.objectify( sord.util.load( so_dir + 'parameters.py' ) )

# Time histories
t1 = prm.dt * numpy.arange( prm.nt )
t2 = sord.util.ndread( bi_dir + 'time' )
for i, sta in enumerate( [ 'P1', 'P2' ] ):
    pylab.figure(i+1)
    pylab.clf()
    pylab.subplot( 2, 1, 1 )
    f1 = 1e-6 * sord.util.ndread( so_dir + 'out/' + sta + 'a-ts1' )
    f2 = sord.util.ndread( bi_dir + sta + '-ts' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.axis([ 1., 11., 60., 85. ])
    pylab.title( sta, position=(0.05,0.83), ha='left', va='center' )
    pylab.ylabel( 'Shear stress (MPa)' )
    pylab.gca().set_xticklabels([])
    pylab.draw()
    pylab.subplot( 2, 1, 2 )
    f1 = sord.util.ndread( so_dir + 'out/' + sta + 'a-su1' )
    f2 = sord.util.ndread( bi_dir + sta + '-su' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.ylabel( 'Slip (m)' )
    pylab.hold( True )
    f1 = sord.util.ndread( so_dir + 'out/' + sta + 'a-sv1' )
    f2 = sord.util.ndread( bi_dir + sta + '-sv' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.axis([ 1., 11., -0.5, 3.5 ])
    pylab.title( sta, position=(0.05,0.83), ha='left', va='center' )
    pylab.ylabel( 'Slip rate (m/s)' )
    pylab.xlabel( 'Time (s)' )
    pylab.gca().set_yticks([0., 1., 2., 3.])
    pylab.draw()

# Rupture time contour
v = 0.5 * numpy.arange( -20, 20 )
for f in prm.fieldio:
    if f[7] is 'trup': break
ii = f[6]
n = [ ( i[1] - i[0] ) / i[2] + 1 for i in ii[:2] ]
x1 = 0.001 * sord.util.ndread( so_dir + 'out/flt-x1',   n )
x2 = 0.001 * sord.util.ndread( so_dir + 'out/flt-x2',   n )
f = sord.util.ndread( so_dir + 'out/flt-trup', n )
pylab.figure(3)
pylab.clf()
pylab.contour( x1, x2, f, v, colors='k' )
pylab.hold( True )
n = 300, 150
dx = 0.1
x1 = dx * numpy.arange( n[0] )
x2 = dx * numpy.arange( n[1] )
x1 = x1 - 0.5 * x1[-1]
x2 = x2 - 0.5 * x2[-1]
x2, x1 = numpy.meshgrid( x2, x1 )
trup = sord.util.ndread( bi_dir + 'trup', n )
pylab.contour( x1, x2, -trup, v, colors='k' )
pylab.axis( 'image' )
#pylab.axis( [ -15., 15., -7.5, 7.5 ] )
pylab.axis( [ -15., 0., -7.5, 0. ] )
pylab.draw()

pylab.show()

