#!/usr/bin/env python
"""
Swab byteorder for 32bit float binary files
"""
import os, sys, numpy

nb = 4
block = 64*1024*1024
dtype = numpy.float32

if len( sys.argv ) == 1:
    print sys.byteorder

for filename in sys.argv[1:]:
    n = os.path.getsize( filename )
    if not n % nb:
        n /= nb
        f0 = open( filename, 'rb' )
        f1 = open( filename + '.swab', 'wb' )
        i = 0
        while i < n:
            b = min( n-i, block )
            r = numpy.fromfile( f0, dtype=dtype, count=b )
            r.byteswap( True ).tofile( f1 )
            i += b
            sys.stdout.write( '\r%s %3d%%' % ( filename, 100. * i / n ) )
            sys.stdout.flush()
        print

