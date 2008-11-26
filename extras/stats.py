#!/usr/bin/env python
"""
Print statistics of 32bit float binary files
"""
import os, sys, numpy

block = 64*1024*1024
nb = 4
try:
    endian = open( 'endian', 'r' ).read()
    dtype = numpy.dtype( numpy.float32 ).newbyteorder( endian )
except:
    dtype = numpy.float32

print '         Min           Max          Mean             N'
for f in sys.argv[1:]:
    n = os.path.getsize( f )
    if not n % nb:
        n /= nb
        fh = file( f, 'r' )
        r = numpy.fromstring( fh.read( block ), dtype=dtype )
        rsum = 0.
        rmin = numpy.inf
        rmax = -numpy.inf
        while r.nbytes:
            rsum += r.sum()
            rmin = min( rmin, r.min() )
            rmax = max( rmax, r.max() )
            r = numpy.fromstring( fh.read( block ), dtype=dtype )
        print '%12g  %12g  %12g  %12d %s' % ( rmin, rmax, rsum/n, n, f )

