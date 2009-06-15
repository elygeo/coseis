#!/usr/bin/env python
"""
General utilities
"""
import os, sys, shutil, re

class Object:
    """
    Empty class for creating objects with addributes.
    """
    pass

def objectify( d ):
    """
    Convert dict to object attributes.
    """
    o = Object()
    for k, v in d.iteritems():
        setattr( o, k, v )
    return o

def dictify( o ):
    """
    Convert object attributes to dict.
    """
    d = {}
    for k in dir( o ):
        d[k] = getattr( o, k )
    return d

def prune( d, pattern='(_)|(^.$)', types=None ):
    """
    Delete dictionary keys with specified name pattern or types
    Default types are: functions and modules.
    """
    if types is None:
        types = type( re ), type( re.compile )
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) in types:
            del( d[k] )

def save( fd, d, expand=None, ignore='(_)|(^.$)', types=None ):
    """
    Write variables from a dict into a Python source file.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ), 'w' )
    if expand is None:
        expand = []
    if types is None:
        types = type( re ), type( re.compile )
    grep = re.compile( ignore )
    for k in sorted( d ):
        if not grep.search( k ) and type( d[k] ) not in types and k not in expand:
            fd.write( '%s = %r\n' % ( k, d[k] ) )
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
                sys.exit( 'Can expand %s type %s' % ( k, type( d[k] ) ) )
    fd.close()
    return

def loadmeta( path='.' ):
    """
    Load SORD metadata.
    """
    path = os.path.expanduser( path )
    meta = {}
    f = os.path.join( path, 'meta.py' )
    if os.path.isfile( f ):
        exec open( f ) in meta
    else:
        f = os.path.join( path, 'conf.py' )
        if os.path.isfile( f ):
            cfg = {}
            exec open( f ) in cfg
            for k in 'name', 'rundate', 'rundir', 'user', 'os_', 'dtype':
                meta[k] = cfg[k]
        f = os.path.join( path, 'parameters.py' )
        if os.path.isfile( f ):
            exec open( f ) in meta
            out = {}
            for f in meta['fieldio']:
                ii, filename = f[6], f[8]
                if filename is not '-':
                    out[filename] = ii
            f = os.path.join( path, 'locations.py' )
            if os.path.isfile( f ):
                locs = {}
                exec open( f ) in locs
                mm = meta['nn'] + ( meta['nt'], )
                for ii, filename in locs['locations']:
                    if filename is not '-':
                        ii = expand_indices( mm, ii )
                        out[filename] = ii
            meta['indices'] = out
            shape = dict()
            for k in out:
                nn = [ ( i[1] - i[0] ) / i[2] + 1 for i in out[k] ]
                nn = [ n for n in nn if n > 1 ]
                shape[k] = nn
            meta['shape'] = shape
        path = os.path.join( path, 'meta.py' )
        expand = 'shape', 'indices', 'fieldio'
        save( path, meta, expand )
    return objectify( meta )

def expand_indices( shape, indices=None, base=1 ):
    """
    Fill in slice index notation.
    """
    n = len( shape )
    off = int( base )
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
            if indices[i] == 0 and base > 0:
                indices[i] = [base, shape[i] - base + off, 1]
            else:
                indices[i] = [indices[i], indices[i] + 1 - off, 1]
        elif len( indices[i] ) == 0:
            indices[i] = [base, shape[i] - base + off, 1]
        elif len( indices[i] ) == 2:
            indices[i] = list( indices[i] ) + [1]
        elif len( indices[i] ) == 3:
            indices[i] = list( indices[i] )
        elif len( indices[i] ) == 1:
            indices[i] = [indices[i][0], indices[i][0] + 1 - off, 1]
        else:
            sys.exit( 'error in indices: %r' % indices )
        if  indices[i][0] < 0:
            indices[i][0] = indices[i][0] + shape[i] + off
        if  indices[i][1] < 0:
            indices[i][1] = indices[i][1] + shape[i] + off
        indices[i] = tuple([ int( j ) for j in indices[i] ])
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
    import numpy
    from numpy import array, fromfile
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ) )
    if not shape:
        return numpy.fromfile( fd, dtype )
    elif type( shape ) == int:
        mm = [shape]
    else:
        mm = list( shape )
    ndim = len( mm )
    ii = expand_indices( mm, indices )
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
    f = numpy.empty( nn, dtype )
    itemsize = numpy.dtype( dtype ).itemsize
    offset = numpy.array( i0, 'd' )
    stride = numpy.cumprod( [1] + mm[:0:-1], dtype='d' )[::-1] * itemsize
    for j in xrange( nn[0] ):
        for k in xrange( nn[1] ):
            for l in xrange( nn[2] ):
                i = ( stride * ( offset + array( [j, k, l, 0] ) ) ).sum()
                fd.seek( long(i), 0 )
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
    percent =  100. * i / n
    remain = int( t * (100. / percent - 1.) )
    h = remain / 3600
    m = remain / 60 % 60
    s = remain % 60
    sys.stdout.write( '\r%3d%%  %02d:%02d:%02d' % ( percent, h, m, s ) )
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
    Remove path file from site-packages directory
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
    print( 'Installing ' + dst )
    print( 'from ' + src )
    try:
        shutil.rmtree( dst )
    except( OSError ):
        pass
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
    print( 'Removing ' + path )
    if os.path.isdir( path ):
        try:
            shutil.rmtree( path )
        except( OSError ):
            sys.exit( 'No write permission for Python directory' )
    return

