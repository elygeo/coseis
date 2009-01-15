#!/usr/bin/env python
"""
Print statistics of 32bit float binary files
"""
import os, sys, numpy

nb = 4
block = 64*1024*1024

try:
    endian = open( 'endian', 'rb' ).read()
    dtype = numpy.dtype( numpy.float32 ).newbyteorder( endian )
except:
    dtype = numpy.float32

print '         Min          Max         Mean            N'
for filename in sys.argv[1:]:
    n = os.path.getsize( filename )
    if not n % nb:
        n /= nb
        fh = open( filename, 'rb' )
        rmin = numpy.inf
        rmax = -numpy.inf
        rsum = 0.
        i = 0
        while i < n:
            b = min( n-i, block )
            r = numpy.fromfile( fh, dtype=dtype, count=b )
            rmin = min( rmin, r.min() )
            rmax = max( rmax, r.max() )
            rsum += r.sum()
            i += b
        print '%12g %12g %12g %12d %s' % ( rmin, rmax, rsum/n, n, filename )

