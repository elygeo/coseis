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
pylab.figure(1)
pylab.clf()
pylab.pcolor( x1, x2, f )

# Rupture time
f = sord.util.ndread( so_dir + 'out/flt_trup', n )
pylab.figure(2)
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

# Show
pylab.axis( 'image' )
pylab.draw()
pylab.show()

