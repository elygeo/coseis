#!/usr/bin/env python
"""
TPV3
"""
import math, numpy, pylab, sord

bi_dir = '../../../bi/'
so_dir = ''

# SORD
prm = sord.util.objectify( sord.util.load( so_dir + 'parameters.py' ) )
for f in prm.fieldio:
    if f[7] is 'trup': break
ii = f[6]
n = [ ( i[1] - i[0] ) / i[2] + 1 for i in ii[:2] ]
x1 = sord.util.ndread( so_dir + 'out/flt_x1',   n )
x2 = sord.util.ndread( so_dir + 'out/flt_x2',   n )

# Initial shear stress
f = sord.util.ndread( so_dir + 'out/flt_tsm0', n )
pylab.figure(4)
pylab.clf()
pylab.pcolor( x1, x2, f )
pylab.draw()

# Rupture time
f = sord.util.ndread( so_dir + 'out/flt_trup', n )
pylab.figure(1)
pylab.clf()
pylab.contour( x1, x2, f )
pylab.hold( True )

# BI
n = 300, 150
dx = 100.
x1 = dx * numpy.arange( n[0] )
x2 = dx * numpy.arange( n[1] )
x1 = x1 - 0.5 * x1[-1]
x2 = x2 - 0.5 * x2[-1]
x2, x1 = numpy.meshgrid( x2, x1 )
trup = sord.util.ndread( bi_dir + 'trup', n )
pylab.contour( x1, x2, trup )
pylab.axis( 'image' )
pylab.draw()

# Time histories
t1 = prm.dt * numpy.arange( prm.nt )
t2 = sord.util.ndread( bi_dir + 'time' )
for i, sta in enumerate( [ 'P1', 'P2' ] ):
    pylab.figure(i+2)
    pylab.clf()

    pylab.subplot( 2, 1, 1 )
    f1 = 1e-6 * sord.util.ndread( so_dir + 'out/' + sta + 'a_ts1' )
    f2 = sord.util.ndread( bi_dir + sta + '-ts' )
    pylab.plot( t1, f1, t2, f2 )
    pylab.ylabel( 'Shear stress (MPa)' )
    pylab.xlabel( 'Time (s)' )
    pylab.draw()

    pylab.subplot( 2, 1, 2 )
    f1 = sord.util.ndread( so_dir + 'out/' + sta + 'a_su1' )
    f2 = sord.util.ndread( bi_dir + sta + '-su' )
    pylab.plot( t1, f1, t2, f2 )
    pylab.ylabel( 'Slip (m)' )
    pylab.xlabel( 'Time (s)' )
    pylab.hold( True )
    f1 = sord.util.ndread( so_dir + 'out/' + sta + 'a_sv1' )
    f2 = sord.util.ndread( bi_dir + sta + '-sv' )
    pylab.plot( t1, f1, t2, f2 )
    pylab.ylabel( 'Slip rate (m/s)' )
    pylab.xlabel( 'Time (s)' )
    pylab.draw()


pylab.show()

