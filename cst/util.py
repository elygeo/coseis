"""
General utilities
"""
import os, sys, re
import numpy as np

class namespace:
    """
    Namespace with object attributes initialized from a dict.
    """
    def __init__( self, d ):
        self.__dict__.update( d )


def prune( d, pattern=None, types=None ):
    """
    Delete dictionary keys with specified name pattern or types

    Parameters
    ----------
        d : dict of parameters
        pattern : regular expression of parameter names to prune
            default = '(^_)|(_$)|(^.$)|(^..$)'
        types : list of parameters types to keep
            default = Numpy types + [NoneType, bool, str, int, lone, float, tuple, list, dict]
            Functions, classes, and modules are pruned by default.

    >>> prune( {'aa': 0, 'aa_': 0, '_aa': 0, 'a_a': 0, 'b_b': prune} )
    {'a_a': 0}
    """
    if pattern is None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'

    if types is None:
        types = set(
            np.typeDict.values() +
            [type(None), bool, str, int, long, float, tuple, list, dict]
        )
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) not in types:
            del( d[k] )
    return d


def open_excl( filename, *args ):
    """
    Thread-safe exclusive file open. Silent return if exists.
    """
    if os.path.exists( filename ):
        return
    try:
        os.mkdir( filename + '.lock' )
    except:
        return
    fh = open( filename, *args )
    os.rmdir( filename + '.lock' )
    return fh


def save( fd, d, expand=None, keep=None, header='', prune_pattern=None, prune_types=None ):
    """
    Write variables from a dict into a Python source file.
    """
    if type( d ) is not dict:
        d = d.__dict__
    if expand is None:
        expand = []
    prune( d, prune_pattern, prune_types )
    out = header
    for k in sorted( d ):
        if k not in expand and (keep is None or k in keep):
            out += '%s = %r\n' % (k, d[k])
    for k in expand:
        if k in d:
            if type( d[k] ) is tuple:
                out += k + ' = (\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ')\n'
            elif type( d[k] ) is list:
                out += k + ' = [\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ']\n'
            elif type( d[k] ) is dict:
                out += k + ' = {\n'
                for item in sorted( d[k] ):
                    out += '    %r: %r,\n' % (item, d[k][item])
                out += '}\n'
            else:
                sys.exit( 'Cannot expand %s type %s' % ( k, type( d[k] ) ) )
    if fd is not None:
        if type( fd ) is not file:
            fd = open( os.path.expanduser( fd ), 'w' )
        fd.write( out )
    return out


def load( fd, d=None, prune_pattern=None, prune_types=None ):
    """
    Load variables from Python source files.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ) )
    if d is None:
        d = {}
    exec fd in d
    prune( d, prune_pattern, prune_types )
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
        elif len( indices[i] ) in (1, 3):
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


def ndread( fd, shape=None, indices=None, dtype='f', order='F', nheader=0 ):
    """
    Read n-dimentional array subsection from binary file.

    Parameters
    ----------
        fd :      Source filename or file object.
        indices : Specify array subsection.
        shape :   Dimensions of the source array.
        dtype :   Numpy style data-type. Default is 'f' (native float)
                  '<f' : little endian float
                  '>f' : big endian float
                  '<d' : little endian double precision
                  '>d' : big endian double precision
        order :   'F' first index varies fastest, or 'C' last index varies fastest.
        nheader : Number of bytes to skip at the start of the file.
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
    ii = expand_slice( mm, indices )
    if order is 'F':
        ii = ii[::-1]
        mm = mm[::-1]
    elif order is not 'C':
        sys.exit( "Invalid order %s, must be 'C' or 'F'" % order )
    i0 = [ i[0] - 1        for i in ii ]
    nn = [ i[1] - i[0] + 1 for i in ii ]
    nn0 = nn[:]
    ndim = len( mm )
    for i in range( ndim-1, 0, -1 ):
        if mm[i] == nn[i]:
            i0[i-1] = i0[i-1] * mm[i]
            nn[i-1] = nn[i-1] * mm[i]
            mm[i-1] = mm[i-1] * mm[i]
            del i0[i], nn[i], mm[i]
    if len( mm ) > 4:
        sys.exit( 'To many slice dimensions' )
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
                i = nheader + ( stride * ( offset + array( [j, k, l, 0] ) ) ).sum()
                fd.seek( i, 0 )
                f[j,k,l,:] = fromfile( fd, dtype, nn[-1] )
    if order is 'F':
        f = f.reshape( nn0 ).T
    else:
        f = f.reshape( nn0 )
    return f


def progress( t0=None, i=None, n=None, message='' ):
    """
    Print progress and time remaining.
    """
    import time
    if t0 is None:
         return time.time()
    if message:
         message += ': '
    t = time.time() - t0
    percent =  100.0 * i / n
    seconds = int( t * (100.0 / percent - 1.0) )
    sys.stdout.write( '\r%s%3d%% done, %.0f s remaining  ' % (message, percent, seconds) )
    sys.stdout.flush()
    if i == n:
        print('')
    return

