#!/usr/bin/env python
"""
Convert SRF file to slip vectors and fault normals

Reads Standard Rupture Format by Graves:
http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
"""
import sys, numpy

filename = sys.argv[1]
fh = open( filename, 'r' )
version = fh.readline().split()[0]
k = fh.readline().split() + fh.readline().split() + fh.readline().split()

# Optional header block
if k[0] == 'PLANE':
    nsegments  = int(   k[1]  )
    nsource2   = int(   k[4]  ), int(   k[5]  )			# number of subfaults
    length     = float( k[6]  ), float( k[7]  )			# fault length and width
    plane      = float( k[8]  ), float( k[9]  )			# strike and dip
    topcenter  = float( k[2]  ), float( k[3]  ), float( k[10] )	# lon, lat, depth
    hypocenter = float( k[11] ), float( k[12] )			# in strike and dip coords
    k = fh.readline().split() + fh.readline().split() + fh.readline().split()

# Data block
if k[0] != 'POINTS':
    sys.exit( 'error' )
nsource = int( k[1] )
nt = []
lon = []
lat = []
depth = []
for isrc in range( nsource ):
    if isrc == 5: sys.exit()
    lon   += [ float( k[2] ) ]
    lat   += [ float( k[3] ) ]
    depth += [ float( k[4] ) ]
    strike = float( k[5] )
    dip    = float( k[6] )
    rake   = float( k[10] )
    area   = float( k[7] )
    t0     = float( k[8] )
    dt     = float( k[9] )
    slip   = float( k[11] ), float( k[13] ), float( k[15] )
    nt3    = float( k[12] ), float( k[14] ), float( k[16] )
    nt    += max( nt3 )
    sv3    = []
    for n in nt3
        i = 0
        sv = []
        while i < n:
            k   = fh.readline().split()
            i  += len( k )
            sv += [ float( k_ ) for k_ in k ]
        sv3 += numpy.array( sv )

