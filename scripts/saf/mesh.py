#!/usr/bin/env python
"""
Fault surface and topography conforming mesh
"""
import os, sys, numpy, sim, sord, cvm

writing = False
writing = True

# CVM setup
np = sim.np3[0] * sim.np3[1] * sim.np3[2]
nn = ( sim.nn[0] - 1 ) * ( sim.nn[1] - 1 ) * ( sim.nn[2] - 1 )
cfg = cvm.stage( dict( np=np, nn=nn ) )
dir = cfg.rundir

# fault parameters
n = 1991, 161
d = int( sim.dx[0] / 100.0 + 0.0001 )
tn = numpy.fromfile( 'ts22-tn', 'f' ).reshape( n[::-1] )[::d,::d].T
ts = numpy.fromfile( 'ts22-ts', 'f' ).reshape( n[::-1] )[::d,::d].T
dc = numpy.fromfile( 'ts22-dc', 'f' ).reshape( n[::-1] )[::d,::d].T
tn.tofile( os.path.join( dir, 'tn' ) )
ts.tofile( os.path.join( dir, 'ts' ) )
dc.tofile( os.path.join( dir, 'dc' ) )
n = tn.shape

# fault indices
xf = sim._xf
yf = sim._yf
kf = sim._kf - 1
lf = sim._lf[1] - 1
jf = sim._jf[0] - 1, sim._jf[1]
if jf[1] - jf[0] != n[0] or lf + 1 != n[1]:
    sys.exit( 'error in fault indices' )

# node mesh
x = numpy.arange( sim.nn[0] ) * sim.dx[0]
y = numpy.arange( sim.nn[1] ) * sim.dx[1]
z = numpy.arange( sim.nn[2] ) * sim.dx[2]
yy, xx = numpy.meshgrid( y, x )

# interpolate fault
df = numpy.sqrt( numpy.diff( xf ) ** 2 + numpy.diff( yf ) ** 2 )
rf = numpy.r_[ 0.0, numpy.cumsum( df ) ]
j  = [ jf[0] ] + [ jf[0] + 1 + int( r / sim.dx[0] ) for r in rf[1:-1] ] + [ jf[1] ]
for i in range( len( j ) - 1 ):
    j1, j2 = j[i], j[i+1]
    w = ( sim.dx[0] * ( numpy.arange( j1, j2 ) - jf[0] ) - rf[i] ) / ( rf[i+1] - rf[i] )
    xx[j1:j2,kf] = xf[i] + w * ( xf[i+1] - xf[i] )
    yy[j1:j2,kf] = yf[i] + w * ( yf[i+1] - yf[i] )

# constant volume elements next to the fault
h = xf[-1] - xf[0], yf[-1] - yf[0]
m = numpy.sqrt( h[0] * h[0] + h[1] * h[1] )
h = h[0] / m, h[1] / m
j1, j2 = jf[0], jf[-1]
xx[j1:j2,kf-1] = xx[j1:j2,kf] + sim.dx[1] * h[1]
xx[j1:j2,kf+1] = xx[j1:j2,kf] - sim.dx[1] * h[1]
yy[j1:j2,kf-1] = yy[j1:j2,kf] - sim.dx[1] * h[0]
yy[j1:j2,kf+1] = yy[j1:j2,kf] + sim.dx[1] * h[0]

# fault double nodes
xx[:,kf+1:] = xx[:,kf:-1].copy()
yy[:,kf+1:] = yy[:,kf:-1].copy()

# blend fault to x-boundaries
i1 = sim.npml
i2 = jf[0]
h = 1.0 / ( i2 - i1 )
for i in xrange( i1+1, i2 ):
    xx[i,:] = xx[i1,:]*h*(i2-i) + xx[i2,:]*h*(i-i1)
    yy[i,:] = yy[i1,:]*h*(i2-i) + yy[i2,:]*h*(i-i1)
i1 = jf[-1] - 1
i2 = x.size - sim.npml - 1
h = 1.0 / ( i2 - i1 )
for i in xrange( i1+1, i2 ):
    xx[i,:] = xx[i1,:]*h*(i2-i) + xx[i2,:]*h*(i-i1)
    yy[i,:] = yy[i1,:]*h*(i2-i) + yy[i2,:]*h*(i-i1)

# blend fault to y-boundaries
i1 = sim.npml
i2 = kf - 1
h = 1.0 / ( i2 - i1 )
for i in xrange( i1+1, i2 ):
    xx[:,i] = xx[:,i1]*h*(i2-i) + xx[:,i2]*h*(i-i1)
    yy[:,i] = yy[:,i1]*h*(i2-i) + yy[:,i2]*h*(i-i1)
i1 = kf + 2
i2 = y.size - sim.npml - 1
h = 1.0 / ( i2 - i1 )
for i in xrange( i1+1, i2 ):
    xx[:,i] = xx[:,i1]*h*(i2-i) + xx[:,i2]*h*(i-i1)
    yy[:,i] = yy[:,i1]*h*(i2-i) + yy[:,i2]*h*(i-i1)

# node X/Y mesh
xx = numpy.array( xx, 'f' )
yy = numpy.array( yy, 'f' )
if writing:
    xx.T.tofile( os.path.join( dir, 'x' ) )
    yy.T.tofile( os.path.join( dir, 'y' ) )
else:
    import pylab
    pylab.figure( 1 )
    pylab.clf()
    pylab.plot( xx, yy, 'k-' )
    pylab.hold( True )
    pylab.plot( xx.T, yy.T, 'k-' )
    pylab.plot( xf, yf, 'ko--' )
    pylab.axis( 'image' )
    pylab.draw()
    pylab.show()

# lon/lat
xx, yy = sim.projection( xx, yy, inverse=True )
xx = numpy.array( xx, 'f' )
yy = numpy.array( yy, 'f' )

# topography elevation
n = 960, 780
dll = 0.5 / 60.0
lon0 = -121.5 + 0.5 * dll
lat0 =   30.5 + 0.5 * dll
topo = numpy.fromfile( 'data/socal-topo.f32', 'f' ).reshape( n[::-1] ).T
zz = sord.coord.interp2( lon0, lat0, dll, dll, topo, xx, yy )
zz = numpy.array( zz, 'f' )
if writing:
    zz.T.tofile( os.path.join( dir, 'z' ) )
else:
    pylab.figure( 2 )
    pylab.clf()
    pylab.imshow( zz.T, interpolation='nearest' )
    pylab.axis( 'image' )
    pylab.gca().invert_yaxis()
    pylab.title( 'Node elevation' )
    pylab.colorbar( orientation='horizontal' )
    pylab.draw()
    pylab.show()

# PML regions are extruded
for w in xx, yy, zz:
    for i in xrange( sim.npml, 0, -1 ):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# node elevation mesh
if writing and sim._topo:
    z0 = zz.mean()
    zz = zz - z0
    n = z.size - sim.npml - lf
    w = 1.0 - numpy.r_[ numpy.zeros(lf), 1.0/(n-1)*numpy.arange(n), numpy.ones(sim.npml) ]
    f3 = open( os.path.join( dir, 'z3' ), 'wb' )
    for i in xrange( z.size ):
        ( z[i] + z0 + w[i] * zz ).T.tofile( f3 )
    f3.close()

# cell centers
z  = -0.5 * ( z[:-1] + z[1:] )
xx = 0.25 * ( xx[:-1,:-1] + xx[1:,:-1] + xx[:-1,1:] + xx[1:,1:] )
yy = 0.25 * ( yy[:-1,:-1] + yy[1:,:-1] + yy[:-1,1:] + yy[1:,1:] )
zz = 0.25 * ( zz[:-1,:-1] + zz[1:,:-1] + zz[:-1,1:] + zz[1:,1:] )

# write 3D lon/lat/depth cell mesh
if writing:
    f1 = open( os.path.join( dir, 'lon' ), 'wb' )
    f2 = open( os.path.join( dir, 'lat' ), 'wb' )
    f3 = open( os.path.join( dir, 'dep' ), 'wb' )
    for i in xrange( z.size ):
        xx.T.tofile( f1 )
        yy.T.tofile( f2 )
    if sim._topo:
        n = z.size - sim.npml - lf
        w = numpy.r_[ numpy.zeros(lf), 1.0/n*(0.5+numpy.arange(n)), numpy.ones(sim.npml) ]
        for i in xrange( z.size ):
            ( z[i] + w[i] * zz ).T.tofile( f3 )
    else:
        for i in xrange( z.size ):
            zz.fill( z[i] )
            zz.T.tofile( f3 )
    f1.close()
    f2.close()
    f3.close()
else:
    pylab.figure( 3 )
    pylab.clf()
    pylab.imshow( zz.T, interpolation='nearest' )
    pylab.axis( 'image' )
    pylab.gca().invert_yaxis()
    pylab.title( 'Cell elevation' )
    pylab.colorbar( orientation='horizontal' )
    pylab.draw()
    pylab.show()

