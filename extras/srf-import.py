#!/usr/bin/env python
"""
Convert SRF file to slip vectors and fault normals

Reads Standard Rupture Format by R. Graves:
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
    sys.exit( 'error' )
nsource = int( k[1] )
ntall = []
lon = []
lat = []
depth = []
nsource = 4
for isrc in range( nsource ):
    nt3 = float( k[12] ), float( k[14] ), float( k[16] )
    nt  = nt3[0] + nt3[1] + nt3[2]
    if nt > 0:
        ntall += max( nt3 )
        lon   += [ float( k[2]  ) ]
        lat   += [ float( k[3]  ) ]
        depth += [ float( k[4]  ) ]
        strike =   float( k[5]  )
        dip    =   float( k[6]  )
        rake   =   float( k[10] )
        area   =   float( k[7]  )
        tm0    =   float( k[8]  )
        dt     =   float( k[9]  )
        slip   =   float( k[11] ), float( k[13] ), float( k[15] )
        sv     =   []
        while len( sv ) < nt:
            sv += fh.readline().split()
        if len( sv ) > nt:
            sys.exit( 'error in sv' )
        it = 0
        nt = max( nt3 )
        sv3 = numpy.zeros( ( 3, nt ) )
        for i, n in enumerate( nt3 )
            sv3[i,0:n] = numpy.array( sv[it:it+n] )
            it += n
        # rotate
        # write

t = numpy.float32
numpy.array( ntall, dtype=t ).tofile( 'src_nt' )
numpy.array( tm0, dtype=t ).tofile( 'src_lat' )
numpy.array( depth, dtype=t ).tofile( 'depth' )
