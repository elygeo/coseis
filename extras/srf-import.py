#!/usr/bin/env python
"""
Convert SRF file to slip vectors and fault normals

Standard Rupture Format by R. Graves:
http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
"""
import sys, numpy, coordinates

filename = sys.argv[1]
fh = open( filename, 'r' )
version = fh.readline().split()[0]
k = fh.readline().split()

# Optional header block
if k[0] == 'PLANE':
    nsegments  = int( k[1] )
    k = fh.readline().split() + fh.readline().split()
    nsource2   = int(   k[2] ), int(   k[3]  )			# number of subfaults
    length     = float( k[4] ), float( k[5]  )			# fault length and width
    plane      = float( k[6] ), float( k[7]  )			# strike and dip
    topcenter  = float( k[0] ), float( k[1]  ), float( k[8] )	# lon, lat, depth
    hypocenter = float( k[9] ), float( k[10] )			# in strike and dip coords
    k = fh.readline().split()

# Data block
if k[0] != 'POINTS':
    sys.exit( 'error reading SRF file' )
nsource = int( k[1] )
nt   = []
dt   = []
t0   = []
dep  = []
lon  = []
lat  = []
stk  = []
dip  = []
rake = []
area = []
pv   = []
for isrc in range( nsource ):
    k = fh.readline().split() + fh.readline().split()
    nt0 = int( k[10] ), int( k[12] ), int( k[14] )
    if sum( nt0 ) > 0:
        nt   += [ nt0 ]
        dt   += [ float( k[7] ) ]
        t0   += [ float( k[6] ) ]
        dep  += [ float( k[2] ) ]
        lon  += [ float( k[0] ) ]
        lat  += [ float( k[1] ) ]
        stk  += [ float( k[3] ) ]
        dip  += [ float( k[4] ) ]
        rake += [ float( k[8] ) ]
        area += [ float( k[5] ) ]
        sv    = []
        while len( sv ) < sum( nt0 ):
            sv += fh.readline().split()
        pv += [ float( f ) for f in sv ]

# NumPy arrays
nt   = numpy.array( nt )
dt   = numpy.array( dt )
t0   = numpy.array( t0 )
dep  = numpy.array( dep )
lon  = numpy.array( lon )
lat  = numpy.array( lat )
stk  = numpy.array( stk )
dip  = numpy.array( dip )
rake = numpy.array( rake )
area = numpy.array( area )
pv   = numpy.array( pv )

# Process
nsource = len( dt )
x1, x2 = coordinates.ll2ts( lon, lat )
stk = stk + coordinates.tsrotation( lon, lat )[1]
svec = coordinates.slipvectors( stk, dip, rake ).T.swapaxes(0,1).T
#nhat = numpy.array( 3 * [ area * svec[2] ] )

