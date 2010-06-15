#!/usr/bin/env python
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
lon, lat = (-120.0, -114.5), (32.5, 35.0)
delta = 0.5 / 60.0

# create mesh
x = np.arange( lon[0], lon[1] + delta/2, delta )
y = np.arange( lat[0], lat[1] + delta/2, delta )
x, y = np.meshgrid( x, y )
z = 500.0 * np.ones_like( x )

# CVM setup
job = cst.cvm.stage( nsample=x.size )
path = job.rundir + os.sep

# write CVM input files
np.array( x, 'f' ).tofile( path + 'lon' )
np.array( y, 'f' ).tofile( path + 'lat' )
np.array( z, 'f' ).tofile( path + 'dep' )

# run CVM job and read Vs
cst.cvm.launch( job, run='exec' )
v = np.fromfile( path + 'vs', 'f' ).reshape( x.shape )

# plot
fig = plt.figure( figsize=(6.4, 3.6) )
ax = plt.gca()
im = ax.imshow( v, extent=lon+lat, origin='lower', interpolation='nearest' )
x, y = cst.data.mapdata( 'coastlines', 'high', (lon, lat), 100.0 )
ax.plot( x-360.0, y, 'k-' )
ax.set_aspect( 1.0 / np.cos( 33.75 / 180.0 * np.pi ) )
ax.axis( lon+lat )
f = path + 'cvm4-vs500.png'
print f
fig.savefig( f )

