#!/usr/bin/env python
"""
Rectangular mesh for basin depth calculation
"""
import os, numpy, coord, cvm

version = 'cvm4'
version = 'cvm3'
up = 1
np = 64
dx = 400.0
dz = 50.0
L = 600000.0, 300000.0, 11000.0

# Node mesh
x = numpy.arange( 0.5*dx, L[0], dx )
y = numpy.arange( 0.5*dx, L[1], dx )
z = numpy.arange( 0.0, L[2]+0.5*dz, dz )
if up:
    z = z[::-1]
xx, yy = numpy.meshgrid( x, y )
nn = x.size, y.size, z.size
n = nn[0] * nn[1] * nn[2]
print 'nn = %r' % list( nn )

# CVM setup
cfg = cvm.stage( dict( np=np, nn=n, name=version ) )
dir = cfg.rundir
numpy.savetxt( os.path.join( dir, 'nn' ), nn, '%i' )
numpy.savetxt( os.path.join( dir, 'dz' ), [dz] )

# Lon/lat
xx, yy = coord.ll2xy( xx, yy, inverse=True )
xx = numpy.array( xx, 'f4' )
yy = numpy.array( yy, 'f4' )
f1 = open( os.path.join( dir, 'lon' ), 'wb' )
f2 = open( os.path.join( dir, 'lat' ), 'wb' )
for i in xrange( z.size ):
    xx.tofile( f1 )
    yy.tofile( f2 )
f1.close()
f2.close()

# Depth
f3 = open( os.path.join( dir, 'dep'), 'wb' )
for i in xrange( z.size ):
    xx.fill( z[i] )
    xx.tofile( f3 )
f3.close()

