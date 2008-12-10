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
lon = []
lat = []
depth = []
strike = []
dip = []
rake = []
t0 = []
dt = []
nt = []
pv = []
nsource = 4 # XXX
for isrc in range( nsource ):
    nt1, nt2, nt3 = int( k[12] ), int( k[14] ), int( k[16] )
    nt0 = nt1 + nt2 + nt3
    if nt0 > 0:
        nt     += [[ nt1, nt2, nt3 ]]
        lon    += [ float( k[2]  ) ]
        lat    += [ float( k[3]  ) ]
        depth  += [ float( k[4]  ) ]
        strike += [ float( k[5]  ) ]
        dip    += [ float( k[6]  ) ]
        rake   += [ float( k[10] ) ]
        t0     += [ float( k[8]  ) ]
        dt     += [ float( k[9]  ) ]
        area    =   float( k[7]  )
        slip    =   float( k[11] ), float( k[13] ), float( k[15] )
        sv = []
        while len( sv ) < nt0:
            sv += fh.readline().split()
        pv += [[ area * float( f ) for f in sv ]]

# Process
ll2xy = coordinates.ll2ts
rotation = coordinates.tsrotation
nsource = len( dt )
i32 = numpy.int32
f32 = numpy.float32
nt     = numpy.array( nt, dtype=i32 )
lon    = numpy.array( lon, dtype=f32 )
lat    = numpy.array( lat, dtype=f32 )
depth  = numpy.array( depth, dtype=f32 ) * 1000.
strike = numpy.array( strike, dtype=f32 )
dip    = numpy.array( dip, dtype=f32 )
rake   = numpy.array( rake, dtype=f32 )
t0     = numpy.array( t0, dtype=f32 )
dt     = numpy.array( dt, dtype=f32 )

x1, x2 = ll2xy( lon, lat )
strike = strike + rotation( lon, lat )

