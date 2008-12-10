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
    sys.exit( 'error reading SRF file' )
nsource = int( k[1] )
nt   = []
dt   = []
t0   = []
lon  = []
lat  = []
dep  = []
stk  = []
dip  = []
rake = []
pv   = []
nsource = 4 # XXX
for isrc in range( nsource ):
    nt0 = int( k[12] ), int( k[14] ), int( k[16] )
    if sum( nt0 ) > 0:
        nt   += [ nt0 ]
        dt   += [ float( k[9]  ) ]
        t0   += [ float( k[8]  ) ]
        lon  += [ float( k[2]  ) ]
        lat  += [ float( k[3]  ) ]
        dep  += [ float( k[4]  ) ]
        stk  += [ float( k[5]  ) ]
        dip  += [ float( k[6]  ) ]
        rake += [ float( k[10] ) ]
        area  = float( k[7]  )
        sv    = []
        while len( sv ) < sum( nt0 ):
            sv += fh.readline().split()
        pv += [ area * float( f ) for f in sv ]
    k = fh.readline().split() + fh.readline().split() + fh.readline().split()

# NumPy arrays
i32  = numpy.int32
f32  = numpy.float32
nt   = numpy.array( nt, dtype=i32 )
lon  = numpy.array( lon, dtype=f32 )
lat  = numpy.array( lat, dtype=f32 )
dep  = numpy.array( depth, dtype=f32 )
stk  = numpy.array( strike, dtype=f32 )
dip  = numpy.array( dip, dtype=f32 )
rake = numpy.array( rake, dtype=f32 )
t0   = numpy.array( t0, dtype=f32 )
dt   = numpy.array( dt, dtype=f32 )
pv   = numpy.array( pv, dtype=f32 )

# Process
nsource = len( dt )
x1, x2 = coordinates.ll2ts( lon, lat )
stk = stk + coordinates.tsrotation( lon, lat )[1]
shat = coordinates.slipvectors( stk, dip, rake )

