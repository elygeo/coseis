#!/usr/bin/env python
"""
Swab byteorder. Default is 4 byte numbers.
"""
import os, sys, numpy

block = 64*1024*1024
dtype = 'f'
args = []
for a in sys.argv[1:]:
    if a[0] == '-':
        dtype = a[1:].replace( 'l', '<' ).replace( 'b', '>' )
    else:
        args += [ a ]
nb = numpy.dtype( dtype ).itemsize

if len( args ) == 1:
    print( sys.byteorder )

for filename in args:
    if not os.path.isfile( filename ):
        continue
    n = os.path.getsize( filename )
    if n == 0 or n % nb != 0:
        continue
    n /= nb
    f0 = open( filename, 'rb' )
    f1 = open( filename + '.swab', 'wb' )
    i = 0
    while i < n:
        b = min( n-i, block )
        r = numpy.fromfile( f0, dtype=dtype, count=b )
        r.byteswap( True ).tofile( f1 )
        i += b
        sys.stdout.write( '\r%s %3d%%' % ( filename, 100.0 * i / n ) )
        sys.stdout.flush()
    print( '' )

