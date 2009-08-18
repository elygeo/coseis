#!/usr/bin/env python
"""
Mesh and CVM extraction
"""
import os, numpy, cvm, sord, sim

# parameters
path = 'tmp'
ntop = int( -26000.0 / sim.dx[2] + 0.5 )

# topography
n = 960, 780
topo_dll = 0.5 / 60.0
topo_lon0 = -121.5 + 0.5 * dll
topo_lat0 =   30.5 + 0.5 * dll
topo = numpy.fromfile( 'data/socal-topo.f32', 'f' ).reshape( n[::-1] ).T

# map data
for f in 'gmt-socal-coast', 'gmt-socal-borders', 'dlg-ca-roads':
    x, y = numpy.loadtxt( 'data/' + f + '.ll', usecols=(0, 1), unpack=True )
    z = sord.coord.interp2( topo_lon0, topo_lat0, topo_dll, topo_dll, topo, x, y )
    x, y = sim.projection( x, y )
    xyz = 0.001 * numpy.array( [x, y, z] ).T
    numpy.savetxt( os.path.join( path, f + '.xyz' ), xyz, '%.3f' )

# node locations
x = numpy.arange( sim.nn[0] ) * sim.dx[0] - 0.5 * sim.L[0]
y = numpy.arange( sim.nn[1] ) * sim.dx[1] - 0.5 * sim.L[0]
z = numpy.arange( sim.nn[2] ) * sim.dx[2]

# node mesh
yy, xx = numpy.meshgrid( y, x )
zz = numpy.zeros_like( xx )
if 'topo' in sim.grid_:
    lon, lat = sim.projection( xx, yy, inverse=True )
    zz += sord.coord.interp2( topo_lon0, topo_lat0, topo_dll, topo_dll, topo, lon, lat )
if 'sphere' in sim.grid_:
    zz += numpy.sqrt( sim.rearth ** 2 - xx ** 2 - yy ** 2 ) - sim.rearth

# PML regions are extruded
for w in xx, yy, zz:
    for i in xrange( sim.npml+1, 0, -1 ):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# node elevation mesh
path = os.path.expanduser( '~/run/tmp' )
if sim.grid_ != '':
    z0 = zz.mean()
    zz = zz - z0
    n = z.size - ntop - sim.npml
    w = 1.0 - numpy.r_[
        numpy.zeros( ntop ),
        1.0 / (n - 1) * numpy.arange( n ),
        numpy.ones( sim.npml )
    ]
    f3 = open( os.path.join( path, 'z3' ), 'wb' )
    for i in xrange( z.size ):
        numpy.array( z0 + w[i] * zz + z[i], 'f' ).T.tofile( f3 )
    f3.close()

if sim.vm_ == 'cvm':

    # CVM setup
    np = sim.np3[0] * sim.np3[1] * sim.np3[2]
    nn = (sim.nn[0] - 1) * (sim.nn[1] - 1) * (sim.nn[2] - 1)
    cfg = cvm.stage( dict( np=np, nn=nn ) )
    path = cfg.rundir

    # cell center locations
    z  = 0.5 * (z[:-1] + z[1:])
    xx = 0.25 * (xx[:-1,:-1] + xx[1:,:-1] + xx[:-1,1:] + xx[1:,1:])
    yy = 0.25 * (yy[:-1,:-1] + yy[1:,:-1] + yy[:-1,1:] + yy[1:,1:])
    zz = 0.25 * (zz[:-1,:-1] + zz[1:,:-1] + zz[:-1,1:] + zz[1:,1:])

    # write lon/lat/depth mesh
    f1 = open( os.path.join( path, 'lon' ), 'wb' )
    f2 = open( os.path.join( path, 'lat' ), 'wb' )
    f3 = open( os.path.join( path, 'dep' ), 'wb' )
    n = z.size - ntop - sim.npml
    w = 1.0 - numpy.r_[
        numpy.zeros( ntop ),
        1.0 / n * (0.5 + numpy.arange( n )),
        numpy.ones( sim.npml )
    ]
    if 'sphere' in sim.grid_:
        for i in xrange( z.size ):
            lon, lat, dep = sim.projection( xx, yy, z0 + w[i] * zz + z[i], inverse=True )
            dep = sord.coord.interp2( topo_lon0, topo_lat0,
                topo_dll, topo_dll, topo, lon, lat ) - dep
            numpy.array( lon, 'f' ).T.tofile( f1 )
            numpy.array( lat, 'f' ).T.tofile( f2 )
            numpy.array( dep, 'f' ).T.tofile( f3 )
    elif 'topo' in sim.grid_:
        xx, yy = sim.projection( xx, yy, inverse=True )
        xx = numpy.array( xx, 'f' )
        yy = numpy.array( yy, 'f' )
        zz = numpy.array( zz, 'f' )
        for i in xrange( z.size ):
            xx.T.tofile( f1 )
            yy.T.tofile( f2 )
            ( (1.0 - w[i]) * zz - z[i] ).T.tofile( f3 )
    else:
        xx, yy = sim.projection( xx, yy, inverse=True )
        xx = numpy.array( xx, 'f' )
        yy = numpy.array( yy, 'f' )
        zz = numpy.array( zz, 'f' )
        for i in xrange( z.size ):
            xx.T.tofile( f1 )
            yy.T.tofile( f2 )
            zz.fill( z[i] )
            zz.T.tofile( f3 )
    f1.close()
    f2.close()
    f3.close()

