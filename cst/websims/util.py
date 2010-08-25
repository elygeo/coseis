"""
Utilities
"""
import os, sys, re

def findmembers( top='.', member='.member', group='.group', ignore='.ignore' ):
    """
    Walk thourgh directory tree looking for members and groups
    """
    if os.path.exists( os.path.join( top, ignore ) ):
        return []
    if os.path.exists( os.path.join( top, member ) ):
        return [top]
    grouping = group and os.path.exists( os.path.join( top, group ) )
    if grouping:
        group = False
    sims = []
    for path in os.listdir( top ):
        if top is not '.':
            path = os.path.join( top, path )
        if os.path.isdir( path ):
             sims += findmembers( path, member, group, ignore )
    if grouping:
        sims = [sims]
    return sims

class namespace:
    """
    Create a namespace froma a dict.
    """
    def __init__( self, d ):
        self.__dict__.update( d )

def prune( d, pattern=None, types=None ):
    """
    Delete dictionary keys with specified name pattern or types
    Default types are: functions and modules.

    >>> prune( {'a': 0, 'a_': 0, '_a': 0, 'a_a': 0, 'b': prune} )
    {'a_a': 0}
    """
    if pattern == None:
        pattern = '(^_)|(_$)|(^.$)'
    if types is None:
        types = type( re ), type( re.sub )
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) in types:
            del( d[k] )
    return d

def load( fd, d=None, ignore_pattern=None, ignore_types=None ):
    """
    Load variables from Python source files.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ) )
    if d == None:
        d = {}
    exec fd in d
    prune( d, ignore_pattern, ignore_types )
    return namespace( d )

def expand_slice( shape, indices=None, base=1, round=True ):
    """
    Fill in slice index notation.

    >>> expand_slice( [8] )
    [(1, 8, 1)]

    >>> expand_slice( (8, 4), [], 0 )
    [(0, 8, 1), (0, 4, 1)]

    >>> expand_slice( (8, 8, 8, 8, 8), [(), 0, 1.4, 1.6, (-1.6, -1.4, 2)], 1 )
    [(1, 8, 1), (1, 8, 1), (1, 1, 1), (2, 2, 1), (7, 8, 2)]

    >>> expand_slice( (8, 8, 8, 8, 8), [(), 0, 1.9, 2.1, (-2.1, -1.9, 2)], 1.5 )
    [(1, 7, 1), (1, 7, 1), (1, 1, 1), (2, 2, 1), (6, 7, 2)]

    >>> expand_slice( (8, 8, 8, 8, 8), [(), 0, 0.4, 0.6, (-0.6, -0.4, 2)], 0 )
    [(0, 8, 1), (0, 1, 1), (0, 1, 1), (1, 2, 1), (7, 8, 2)]

    >>> expand_slice( (8, 8, 8, 8, 8), [(), 0, 0.9, 1.1, (-1.1, -0.9, 2)], 0.5 )
    [(0, 7, 1), (0, 7, 1), (0, 1, 1), (1, 2, 1), (6, 7, 2)]
    """
    n = len( shape )
    offset = min( 1, int( base ) )
    if indices is None:
        indices = n * [()]
    elif len( indices ) == 0:
        indices = n * [()]
    elif len( indices ) != n:
        sys.exit( 'error in indices: %r' % indices )
    else:
        indices = list( indices )
    for i in range( n ):
        if type( indices[i] ) not in ( tuple, list ):
            indices[i] = [indices[i]]
        elif len( indices[i] ) == 0:
            indices[i] = [base, shape[i] - base + offset, 1]
        elif len( indices[i] ) == 2:
            indices[i] = list( indices[i] ) + [1]
        elif len( indices[i] ) in ( 1, 3 ):
            indices[i] = list( indices[i] )
        else:
            sys.exit( 'error in indices: %r' % indices )
        if  indices[i][0] < 0:
            indices[i][0] = shape[i] + indices[i][0] + offset
        if len( indices[i] ) == 1:
            if indices[i][0] == 0 and base > 0:
                indices[i] = [base, shape[i] - base + offset, 1]
            else:
                indices[i] = [indices[i][0], indices[i][0] + 1 - offset, 1]
        if  indices[i][1] < 0:
            indices[i][1] = shape[i] + indices[i][1] + offset
        if round:
            indices[i][0] = int( indices[i][0] + 0.5 - base + offset )
            indices[i][1] = int( indices[i][1] + 0.5 - base + offset )
        indices[i] = tuple( indices[i] )
    return indices

def ndread( fd, shape=None, indices=None, dtype='f', order='F' ):
    """
    Read n-dimentional array subsection from binary file.

    fd :      Source filename or file object.
    indices : Specify array subsection.
    shape :   Dimensions of the source array.
    dtype :   Numpy style data-type. Default is 'f' (native float)
              '<f' : little endian float
              '>f' : big endian float
              '<d' : little endian double precision
              '>d' : big endian double precision
    order :   'F' first index varies fastest, or 'C' last index varies fastest.
    """
    import numpy as np
    from numpy import array, fromfile
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ) )
    if not shape:
        return np.fromfile( fd, dtype )
    elif type( shape ) == int:
        mm = [shape]
    else:
        mm = list( shape )
    ndim = len( mm )
    ii = expand_slice( mm, indices )
    if order is 'F':
        ii = ii[::-1]
        mm = mm[::-1]
    elif order is not 'C':
        sys.exit( "Invalid order %s, must be 'C' or 'F'" % order )
    i0 = [ ii[i][0] - 1             for i in range( ndim ) ]
    nn = [ ii[i][1] - ii[i][0] + 1  for i in range( ndim ) ]
    nn0 = nn[:]
    for i in range( ndim-1, 0, -1 ):
        if mm[i] == nn[i]:
            i0[i-1] = i0[i-1] * mm[i]
            nn[i-1] = nn[i-1] * mm[i]
            mm[i-1] = mm[i-1] * mm[i]
            del i0[i], nn[i], mm[i]
    if len( mm ) > 4:
        sys.exit( 'To many slice dimentions' )
    i0 = ( [0, 0, 0] + i0 )[-4:]
    nn = ( [1, 1, 1] + nn )[-4:]
    mm = ( [1, 1, 1] + mm )[-4:]
    f = np.empty( nn, dtype )
    itemsize = np.dtype( dtype ).itemsize
    offset = np.array( i0, 'i8' )
    stride = np.cumprod( [1] + mm[:0:-1], dtype='i8' )[::-1] * itemsize
    for j in xrange( nn[0] ):
        for k in xrange( nn[1] ):
            for l in xrange( nn[2] ):
                i = ( stride * ( offset + array( [j, k, l, 0] ) ) ).sum()
                fd.seek( i, 0 )
                f[j,k,l,:] = fromfile( fd, dtype, nn[-1] )
    if order is 'F':
        f = f.reshape( nn0 ).T
    else:
        f = f.reshape( nn0 )
    return f

