#!/usr/bin/env python
"""
General utilities
"""
import os, sys, shutil, re

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

def save( fd, d, expand=None, prune_pattern=None, prune_types=None ):
    """
    Write variables from a dict into a Python source file.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ), 'w' )
    if type( d ) is not dict:
        d = d.__dict__
    if expand is None:
        expand = []
    prune( d, prune_pattern, prune_types )
    for k in sorted( d ):
        if k not in expand:
            fd.write( '%s = %r\n' % (k, d[k]) )
    for k in expand:
        if k in d:
            if type( d[k] ) == tuple:
                fd.write( k + ' = (\n' )
                for item in d[k]:
                    fd.write( repr( item ) + ',\n' )
                fd.write( ')\n' )
            elif type( d[k] ) == list:
                fd.write( k + ' = [\n' )
                for item in d[k]:
                    fd.write( repr( item ) + ',\n' )
                fd.write( ']\n' )
            elif type( d[k] ) == dict:
                fd.write( k + ' = {\n' )
                for item in sorted( d[k] ):
                    fd.write( repr( item ) + ': ' + repr( d[k][item] ) + ',\n' )
                fd.write( '}\n' )
            else:
                sys.exit( 'Cannot expand %s type %s' % ( k, type( d[k] ) ) )
    fd.close()
    return

def load( fd, d=None, prune_pattern=None, prune_types=None ):
    """
    Load variables from Python source files.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ) )
    if d == None:
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

def ndread( fd, shape=None, indices=None, dtype='f', order='F', nheader=0 ):
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
                i = nheader + ( stride * ( offset + array( [j, k, l, 0] ) ) ).sum()
                fd.seek( i, 0 )
                f[j,k,l,:] = fromfile( fd, dtype, nn[-1] )
    if order is 'F':
        f = f.reshape( nn0 ).T
    else:
        f = f.reshape( nn0 )
    return f

def progress( i, n, t ):
    """
    Print progress and time remaining.
    """
    #import datetime
    percent =  100.0 * i / n
    seconds = int( t * (100.0 / percent - 1.0) )
    #datetime.timedelta( seconds=seconds )
    sys.stdout.write( '\r%3d%%  %s' % (percent, seconds) )
    sys.stdout.flush()
    if i == n:
        print('')
    return

def make( compiler, object_, source ):
    """
    An alternative Make that uses state files.
    """
    import glob, difflib
    object_ = os.path.expanduser( object_ )
    source = tuple( os.path.expanduser( f ) for f in source if f )
    statedir = os.path.join( os.path.dirname( object_ ), '.state' )
    if not os.path.isdir( statedir ):
        os.mkdir( statedir )
    statefile = os.path.join( statedir, os.path.basename( object_ ) )
    command = compiler + (object_,) + source
    state = [ ' '.join( command ) + '\n' ]
    for f in source:
        state += open( f ).readlines()
    compile_ = True
    if os.path.isfile( object_ ):
        try:
            oldstate = open( statefile ).readlines()
            diff = ''.join( difflib.unified_diff( oldstate, state, n=0 ) )
            if diff:
                print( diff )
            else:
                compile_ = False
        except( IOError ):
            pass
    if compile_:
        try:
            os.unlink( statefile )
        except( OSError ):
            pass
        print( ' '.join( command ) )
        if os.system( ' '.join( command ) ):
            sys.exit( 'Compile error' )
        open( statefile, 'w' ).writelines( state )
        for pat in '*.o', '*.mod', '*.ipo', '*.il', '*.stb':
            for f in glob.glob( pat ):
                os.unlink( f )
    return compile_

def install_path():
    """
    Install path file in site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    path = os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
    path = os.path.join( get_python_lib(), path )
    src = os.path.dirname( os.path.dirname( os.path.realpath( __file__ ) ) )
    print( 'Installing ' + path )
    print( 'for path ' + src )
    try:
        open( path, 'w' ).write( src )
    except( IOError ):
        sys.exit( 'No write permission for Python directory' )
    return

def uninstall_path():
    """
    Remove path file from site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    path = os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
    path = os.path.join( get_python_lib(), path )
    print( 'Removing ' + path )
    if os.path.isfile( path ):
        try:
            os.unlink( path )
        except( IOError ):
            sys.exit( 'No write permission for Python directory' )
    return

def install():
    """
    Copy package to site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    src = os.path.dirname( os.path.realpath( __file__ ) )
    dst = os.path.basename( os.path.dirname( __file__ ) )
    dst = os.path.join( get_python_lib(), dst )
    if os.path.exists( dst ):
        sys.exit( 'Error: %s exists' % dst )
    print( 'Installing ' + dst )
    print( 'from ' + src )
    try:
        shutil.copytree( src, dst )
    except( OSError ):
        sys.exit( 'No write permission for Python directory' )
    return

def uninstall():
    """
    Remove package from site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    path = os.path.basename( os.path.dirname( __file__ ) )
    path = os.path.join( get_python_lib(), path )
    if not os.path.exists( path ):
        sys.exit( 'Error: %s does not exist' % path )
    print( 'Removing ' + path )
    try:
        shutil.rmtree( path )
    except( OSError ):
        sys.exit( 'No write permission for Python directory' )
    return

if __name__ == '__main__':
    import doctest
    doctest.testmod()

