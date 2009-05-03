#!/usr/bin/env python
"""
Print statistics of 32bit float binary files
"""
import os, sys
from numpy import dtype, fromfile, float64, inf

block = 64*1024*1024
datatype = 'f'
args = []
for a in sys.argv[1:]:
    if a[0] == '-':
        datatype = a[1:].replace( 'l', '<' ).replace( 'b', '>' )
    else:
        args += [ a ]

nb = dtype( datatype ).itemsize

print( '         Min          Max         Mean            N' )
for filename in args:
    n = os.path.getsize( filename )
    if n > 0 and n % nb == 0:
        n /= nb
        fh = open( filename, 'rb' )
        rmin = inf
        rmax = -inf
        rsum = 0.
        i = 0
        while i < n:
            b = min( n-i, block )
            r = fromfile( fh, dtype=datatype, count=b )
            rmin = min( rmin, r.min() )
            rmax = max( rmax, r.max() )
            rsum += float64( r ).sum()
            i += b
        print( '%12g %12g %12g %12d %s' % ( rmin, rmax, rsum/n, n, filename ) )

