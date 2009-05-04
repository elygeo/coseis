#!/usr/bin/env python
"""
Swab byteorder for 32bit float binary files
"""
import os, sys, numpy

block = 64*1024*1024
dtype = 'f'
nb = numpy.dtype( dtype ).itemsize

if len( sys.argv ) == 1:
    print( sys.byteorder )

for filename in sys.argv[1:]:
    n = os.path.getsize( filename )
    if n > 0 and n % nb == 0:
        n /= nb
        f0 = open( filename, 'rb' )
        f1 = open( filename + '.swab', 'wb' )
        i = 0
        while i < n:
            b = min( n-i, block )
            r = numpy.fromfile( f0, dtype=datatype, count=b )
            r.byteswap( True ).tofile( f1 )
            i += b
            sys.stdout.write( '\r%s %3d%%' % ( filename, 100.0 * i / n ) )
            sys.stdout.flush()
        print( '' )

