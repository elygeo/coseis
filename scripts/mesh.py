#!/usr/bin/env python

import numpy, pyproj, scipy.interpolate
import coord

nn = 1056, 752, 202
dx = 100000.0, 100000.0, 10000.0
L = 600000.0, 300000.0, 80000.0
L = 160000.0, 110000.0, 80000.0
x = numpy.arange( 0.5*dx[0], L[0], dx[0] )
y = numpy.arange( 0.5*dx[1], L[1], dx[1] )
z = numpy.arange( 0.5*dx[2], L[2], dx[2] )

xx, yy = numpy.meshgrid( x, y )
zz = numpy.zeros_like( xx )
lon, lat = coord.ts2ll( xx, yy )

#f1 = open( 'lon', 'wb' )
#f2 = open( 'lat', 'wb' )
#f3 = open( 'dep', 'wb' )
for z in numpy.arange( 0.5*dx[2], L[2], dx[2] ):
  zz.fill( L[2] - z )

proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
x = [ 332984.368775764, 334968.783702151, 493193.454179488, 491209.039253102 ]
y = [ 3719052.86981527, 3831684.83903658, 3828897.14563133, 3716265.17641002 ]

interp2d = scipy.interpolate.RectBivariateSpline




lon, lat = proj( x, y, inverse=True )
print lon
print lat
print coord.utmrotation( lon, lat )[1]

x = numpy.array( x ) - x[2]
y = numpy.array( y ) - y[2]
l = 0.001 * numpy.sqrt( x * x + y * y )
print 'ell', l
x = numpy.array( x ) - x[0]
y = numpy.array( y ) - y[0]
l = 0.001 * numpy.sqrt( x * x + y * y )
print 'ell', l, 0.150 * ( numpy.array( nn ) - 1 )
phi = numpy.arctan2( x[1], y[1] ) * 180.0 / numpy.pi
print phi
phi = numpy.arctan2( y[3], x[3] ) * 180.0 / numpy.pi
print phi

import pylab
pylab.plot( x, y, 'k-' )
pylab.show()
