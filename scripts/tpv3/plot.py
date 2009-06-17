#!/usr/bin/env python
"""
TPV3
"""
import numpy, pylab, sord

so_dir = './'; bi_dir = '../../bi/'
so_dir = './run/500/'; bi_dir = 'bi/'
so_dir = './run/150/'; bi_dir = 'bi/'
meta = sord.util.loadmeta( so_dir )
dt = meta.dt
nt = meta.nt

# Time histories
t1 = dt * numpy.arange( nt )
t2 = numpy.fromfile( bi_dir + 'time', 'f' )
for i, sta in enumerate( ('P1', 'P2') ):
    pylab.figure(i+1)
    pylab.clf()

    pylab.subplot( 2, 1, 1 )
    f1 = 1e-6 * numpy.fromfile( so_dir + 'out/' + sta + 'a-ts1', 'f' )
    f2 = numpy.fromfile( bi_dir + sta + '-ts' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.axis([ 1., 11., 60., 85. ])
    pylab.title( sta, position=(0.05,0.83), ha='left', va='center' )
    pylab.gca().set_xticklabels( [] )
    pylab.ylabel( 'Shear stress (MPa)' )
    leg = pylab.legend( ('SOM', 'BI'), loc=(.78, .6) )

    pylab.subplot( 2, 1, 2 )
    f1 = numpy.fromfile( so_dir + 'out/' + sta + 'a-sv1', 'f' )
    f2 = numpy.fromfile( bi_dir + sta + '-sv', 'f' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.gca().set_yticks( [0, 1, 2, 3] )
    pylab.ylabel( 'Slip rate (m/s)' )

    pylab.gca().twinx()
    f1 = numpy.fromfile( so_dir + 'out/' + sta + 'a-su1', 'f' )
    f2 = numpy.fromfile( bi_dir + sta + '-su', 'f' )
    pylab.plot( t1, f1, 'k-', t2, f2, 'k--' )
    pylab.axis([ 1., 11., -0.5, 3.5 ])
    pylab.gca().set_yticks( [0, 1, 2, 3] )
    lab = pylab.ylabel( 'Slip (m)' )
    pylab.xlabel( 'Time (s)' )
    pylab.title( sta, position=(0.05,0.83), ha='left', va='center' )
    pylab.draw()

# Rupture time contour
v = 0.5 * numpy.arange( -20, 20 )
n = meta.shape['flt-trup']
print n
x1 = 0.001 * numpy.fromfile( so_dir + 'out/flt-x1', 'f' ).reshape( n[::-1] ).T
x2 = 0.001 * numpy.fromfile( so_dir + 'out/flt-x2', 'f' ).reshape( n[::-1] ).T
f = numpy.fromfile( so_dir + 'out/flt-trup', n )
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
trup = numpy.fromfile( bi_dir + 'trup', n )
pylab.contour( x1, x2, -trup, v, colors='k' )
pylab.axis( 'image' )
#pylab.axis( (-15, 15, -7.5, 7.5) )
pylab.axis( (-15, 0, -7.5, 0) )
pylab.draw()
pylab.show()

