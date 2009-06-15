#!/usr/bin/env python
import os, sys, numpy

swab( src, dst, verbose=False, dtype='f', block=64*1024*1024 ):
    """
    Swab byteorder. Default is 4 byte numbers.
    """
    nb = numpy.dtype( dtype ).itemsize
    n = os.path.getsize( f )
    if n == 0 or n % nb != 0:
        return
    n /= nb
    f0 = open( src, 'rb' )
    f1 = open( dst, 'wb' )
    i = 0
    while i < n:
        b = min( n-i, block )
        r = numpy.fromfile( f0, dtype=dtype, count=b )
        r.byteswap( True ).tofile( f1 )
        i += b
        if verbose:
            sys.stdout.write( '\r%s %3d%%' % ( filename, 100.0 * i / n ) )
            sys.stdout.flush()
    if verbose:
        print( '' )
    return

# Command line
if __name__ =='__main__':
    files = []
    for a in sys.argv[1:]:
        if a[0] == '-':
            dtype = a[1:].replace( 'l', '<' ).replace( 'b', '>' )
        else:
            files += [a]
    if len( files ) == 1:
        print( sys.byteorder )
    for f in files:
        if not os.path.isfile( f ):
            continue
        swab( f, f + '.swab', True )

