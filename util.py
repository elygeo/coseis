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

def dictify( o, ignore='(_)|(^.$)' ):
    """
    Convert object attributes to dict.
    """
    d = dict()
    grep = re.compile( ignore )
    for k in dir( o ):
        v = getattr( o, k )
        if not grep.search(k) and type(v) not in [type(os), type(os.walk)]:
            d[k] = v
    return d

def objectify( d, ignore='(_)|(^.$)' ):
    """
    Convert dict to object attributes.
    """
    o = Object()
    grep = re.compile( ignore )
    for k, v in d.iteritems():
        if not grep.search(k) and type(v) not in [type(os), type(os.walk)]:
            setattr( o, k, v )
    return o

def load( filename, d=None, ignore='(_)|(^.$)' ):
    """
    Load variables from a Python source file into a dict.
    """
    if d is None:
        d = dict()
    f = open( os.path.expanduser( filename ) )
    exec f in d
    grep = re.compile( ignore )
    for k in d.keys():
        if grep.search(k) or type(d[k]) in [type(os), type(os.walk)]:
            del( d[k] )
    return d

def save( fd, d, expand=[], ignore='(_)|(^.$)' ):
    """
    Write variables from a dict into a Python source file.
    """
    if type( fd ) is not file:
        fd = open( os.path.expanduser( fd ), 'w' )
    grep = re.compile( ignore )
    for k in sorted( d ):
        if ( not grep.search(k) and
            type(d[k]) not in [type(os), type(os.walk)] and
            k not in expand ):
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
    if os.path.isfile( os.path.join( path, 'meta.py' ) ):
        meta = load( os.path.join( path, 'meta.py' ) )
    else:
        meta = dict()
        if os.path.isfile( os.path.join( path, 'conf.py' ) ):
            cfg = load( os.path.join( path, 'conf.py' ) )
            for k in 'name', 'rundate', 'rundir', 'user', 'os_', 'dtype':
                meta[k] = cfg[k]
        if os.path.isfile( os.path.join( path, 'parameters.py' ) ):
            load( os.path.join( path, 'parameters.py' ), meta )
            out = dict()
            for f in meta['fieldio']:
                ii, filename = f[6], f[8]
                if filename is not '-':
                    out[filename] = ii
            if os.path.isfile( os.path.join( path, 'locations.py' ) ):
                locs = load( os.path.join( path, 'locations.py' ) )
                mm = meta['nn'] + ( meta['nt'], )
                for ii, filename in locs['locations']:
                    if filename is not '-':
                        ii = expand_indices( ii, mm )
                        out[filename] = ii
            meta['indices'] = out
            shape = dict()
            for k in out:
                nn = [ ( i[1] - i[0] ) / i[2] + 1 for i in out[k] ]
                nn = [ n for n in nn if n > 1 ]
                shape[k] = nn
            meta['shape'] = shape
        save( os.path.join( path, 'meta.py' ), meta, [ 'shape', 'indices', 'fieldio' ] )
    return objectify( meta )

def expand_indices( indices, shape, base=1 ):
    """
    Fill in slice index notation.
    """
    n = len( shape )
    off = int( base )
    if len( indices ) == 0:
        indices = n * [()]
    elif len( indices ) != n:
        sys.exit( 'error in indices: %r' % indices )
    else:
        indices = list( indices )
    for i in range( n ):
        if type( indices[i] ) not in ( tuple, list ):
            if indices[i] == 0 and base > 0:
                indices[i] = [ base, shape[i] - base + off, 1 ]
            else:
                indices[i] = [ indices[i], indices[i] + 1 - off, 1 ]
        elif len( indices[i] ) == 0:
            indices[i] = [ base, shape[i] - base + off, 1 ]
        elif len( indices[i] ) == 2:
            indices[i] = list( indices[i] ) + [ 1 ]
        elif len( indices[i] ) == 3:
            indices[i] = list( indices[i] )
        elif len( indices[i] ) == 1:
            indices[i] = [ indices[i][0], indices[i][0] + 1 - off, 1 ]
        else:
            sys.exit( 'error in indices: %r' % indices )
        if  indices[i][0] < 0:
            indices[i][0] = indices[i][0] + shape[i] + off
        if  indices[i][1] < 0:
            indices[i][1] = indices[i][1] + shape[i] + off
        indices[i] = tuple([ int( j ) for j in indices[i] ])
    return indices

def ndread( fd, shape=None, indices=[], dtype='f', order='F' ):
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
        fd = open( os.path.expanduser( fd ), 'rb' )
    if not shape:
        return numpy.fromfile( fd, dtype )
    elif type( shape ) == int:
        mm = [ shape ]
    else:
        mm = list( shape )
    ndim = len( mm )
    ii = expand_indices( indices, mm )
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
            i0[i-1] = i0[i-1] * mm[i]; del i0[i]
            nn[i-1] = nn[i-1] * mm[i]; del nn[i]
            mm[i-1] = mm[i-1] * mm[i]; del mm[i]
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

def compile( compiler, object_, source ):
    """
    An alternative to Make that uses state files.
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
        state += open( f, 'r' ).readlines()
    compile = True
    if os.path.isfile( object_ ):
        try:
            oldstate = open( statefile ).readlines()
            diff = ''.join( difflib.unified_diff( oldstate, state, n=0 ) )
            if diff:
                print( diff )
            else:
                compile = False
        except:
            pass
    if compile:
        try:
            os.unlink( statefile )
        except:
            pass
        print( ' '.join( command ) )
        if os.system( ' '.join( command ) ):
            sys.exit( 'Compile error' )
        open( statefile, 'w' ).writelines( state )
        for pat in '*.o', '*.mod', '*.ipo', '*.il', '*.stb':
            for f in glob.glob( pat ):
                os.unlink( f )
    return compile

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
    except:
        sys.exit( 'You do not have write permission for this Python install' )
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
        except:
            sys.exit( 'You do not have write permission for this Python install' )
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
    except:
        pass
    try:
        shutil.copytree( src, dst )
    except:
        sys.exit( 'You do not have write permission for this Python install' )
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
        except:
            sys.exit( 'You do not have write permission for this Python install' )
    return

