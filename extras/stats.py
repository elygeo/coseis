#!/usr/bin/env python
"""
Print statistics of 32bit float binary files
"""
import os, sys, numpy

nb = 4
block = 64*1024*1024

dtype = 'f'
args = []
for a in sys.argv[1:]:
    if a[0] == '-':
        dtype = a[1:]
    else:
        args += [ a ]

print '         Min          Max         Mean            N'
for filename in args:
    n = os.path.getsize( filename )
    if n > 0 and n % nb == 0:
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
            rsum += numpy.float64( r ).sum()
            i += b
        print '%12g %12g %12g %12d %s' % ( rmin, rmax, rsum/n, n, filename )

