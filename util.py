#!/usr/bin/env python
"""
General utilities
"""

def dictify( o ):
    """Convert object attributes to dict"""
    import sys
    d = dict()
    for k in dir( o ):
        v = getattr( o, k )
        if k[0] is not '_' and type(v) is not type(sys):
            d[k] = v
    return d

def objectify( d ):
    """Convert dict to object attributes"""
    import sys
    class obj: pass
    o = obj()
    for k, v in d.iteritems():
        if k[0] is not '_' and type(v) is not type(sys):
            setattr( o, k, v )
    return o

def load( filename, d=None ):
    """Load variables from a Python source file into a dict"""
    import sys
    if d is None: d = dict()
    execfile( filename, d )
    for k in d.keys():
        if k[0] is '_' or type(d[k]) is type(sys): del( d[k] )
    return d

def save( fd, d, expandlist=[] ):
    """Write variables from a dict into a Python source file"""
    import sys
    if type( fd ) is not file: fd = open( fd, 'w' )
    for k in sorted( d ):
        if k[0] is not '_' and type(d[k]) is not type(sys) and k not in expandlist:
            fd.write( '%s = %r\n' % ( k, d[k] ) )
    for k in expandlist:
        fd.write( k + ' = [\n' )
        for line in d[k]:
            fd.write( repr( line ) + ',\n' )
        fd.write( ']\n' )
    fd.close()
    return

def loadmeta( dir='.' ):
    """Load SORD metadata"""
    import os, pprint
    meta = load( os.path.join( dir, 'parameters.py' ) )
    load( os.path.join( dir, 'conf.py' ), meta )
    try:
        load( os.path.join( dir, 'out', 'header.py' ), meta )
        out = meta['indices']
    except:
        out = dict()
        for f in meta['fieldio']:
             ii, field, filename = f[6:9]
             if filename is not '-':
                 out[filename] = ii
        locs = load( os.path.join( dir, 'locations.py' ) )
        mm = meta['nn'] + ( meta['nt'], )
        for ii, filename in locs['locations']:
             if filename is not '-':
                 ii = indices( ii, mm )
                 out[filename] = ii
        meta['indices'] = out
        f = open( os.path.join( dir, 'out', 'header.py' ), 'w' )
        f.write( 'indices = ' + pprint.pformat( out ) )
        f.close()
    shape = dict()
    for k in out:
        nn = [ ( i[1] - i[0] ) / i[2] + 1 for i in out[k] ]
        nn = [ n for n in nn if n > 1 ]
        shape[k] = nn
    meta['shape'] = shape
    return objectify( meta )

def expand_indices( indices, shape, base=1 ):
    """
    Fill in slice index notation.

    FIXME: document
    """
    n = len( shape )
    if len( indices ) == 0:
        indices = n * [()]
    elif len( indices ) != n:
        sys.exit( 'error in indices' )
    indices = list( indices )
    for i in range( n ):
        if type( indices[i] ) == int:
            indices[i] = [ indices[i], indices[i]-base+1, 1 ]
        elif len( indices[i] ) == 0:
            indices[i] = [ base, -1, 1 ]
        else:
            indices[i] = list( indices[i] )
        if  len( indices[i] ) == 2:
            indices[i] = indices[i] + [ 1 ]
        if  indices[i][0] < 0:
            indices[i][0] = indices[i][0] + shape[i] + base
        if  indices[i][1] < 0:
            indices[i][1] = indices[i][1] + shape[i] + 1
        indices[i] = tuple( indices[i] )
    return indices

def ndread( fd, shape=None, indices=[], order='F', dtype=None, endian=None ):
    """
    Read n-dimentional array subsection from binary file.

    fd :      Source filename or file object.
    indices : Specify array subsection.
    shape :   Dimensions of the source array.
    order :   'F' first index varies fastest, or 'C' last index varies fastest.
    dtype :   Data-type of the array. Default is numpy.float32
    endian :  Byte order of the array on disk. 'l' little, 'b' big, or '=' native.
    """
    import numpy
    if not dtype:
        dtype = numpy.dtype( numpy.float32 )
    if endian:
        dtype = dtype.newbyteorder( endian )
    if type( fd ) is not file:
        fd = open( fd, 'rb' )
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
    for i in xrange( ndim-1, 0, -1 ):
        if mm[i] == nn[i]:
            i0[i-1] = i0[i-1] * mm[i]; del i0[i]
            nn[i-1] = nn[i-1] * mm[i]; del nn[i]
            mm[i-1] = mm[i-1] * mm[i]; del mm[i]
    if len( mm ) > 4:
        sys.exit( 'To many slice dimentions' )
    i0 = ( [0,0,0] + i0 )[-4:]
    nn = ( [1,1,1] + nn )[-4:]
    mm = ( [1,1,1] + mm )[-4:]
    f = numpy.empty( nn, dtype )
    offset = numpy.array( i0, dtype=numpy.int64 )
    stride = numpy.cumprod( [1] + mm[:0:-1], dtype=numpy.int64 )[::-1] * dtype.itemsize
    for j in xrange( nn[0] ):
        for k in xrange( nn[1] ):
            for l in xrange( nn[2] ):
                i = numpy.sum( stride * ( offset + numpy.array( [j,k,l,0] ) ) )
                fd.seek( i, 0 )
                f[j,k,l,:] = numpy.fromfile( fd, dtype, nn[-1] )
    if order is 'F':
        f = f.reshape( nn0 ).T
    else:
        f = f.reshape( nn0 )
    return f

def transpose( fd_in, fd_out, shape, axes=None, order='F', hold=2, dtype=None ):
    """
    Transpose binary array on disk.

    fd_in :  Source filename or file object.
    fd_out : Destination filename or file object.
    shape :  Dimensions of the source array.
    axes :   List of axes to permute. If None (the default), reverse dimensions.
    order :  'F' first index varies fastest, or 'C' last index varies fastest.
    hold :   Number of dimensions to hold in memory at once. Default is 2.
    dtype :  Data-type of the array. Default is numpy.float32
    """
    import sys, numpy
    ndim = len( shape )
    if not axes:
        axes = range( ndim )[::-1]
    if not dtype:
        dtype = numpy.dtype( numpy.float32 )
    if len( shape ) != len( axes ):
        sys.exit( 'Length of shape and axes must match: %s, %s' % ( shape, axes ) )
    if min( axes ) == 1:
        axes = [ i-1 for i in axes ]
    if sorted( axes ) != range( ndim ):
        sys.exit( 'bad axes: %s' % axes )
    if order is 'F':
        shape = shape[::-1]
        axes  = [ ndim-i-1 for i in axes[::-1] ]
    elif order is not 'C':
        sys.exit( "Invalid order %s, must be 'C' or 'F'" % order )
    hold += 1
    shape = numpy.array( list( shape ) + [1], dtype=numpy.int64 )
    axes  = [ i for i in axes if shape[i] > 1 ] + [ndim]
    if len( axes ) < 3:
        sys.exit( 'Nothing to transpose' )
    if type( fd_in ) is not file:
        fd_in = open( fd_in, 'rb' )
    if type( fd_out ) is not file:
        fd_out = open( fd_out, 'wb' )
    n = len( axes ) - hold
    T = numpy.array( axes[n:] )
    T[T.argsort()] = numpy.arange( T.size )
    axes = axes[:n] + sorted( axes[n:] )
    s  = shape[axes]
    w0 = numpy.cumprod( [1] + list( s[:n][:0:-1] ), dtype=numpy.int64 )[::-1]
    w1 = numpy.cumprod( [1] + list( shape[:0:-1] ), dtype=numpy.int64 )[::-1][axes][:n] * dtype.itemsize
    w2 = 0
    i  = n
    ii = ( numpy.diff( axes ) != 1 ).nonzero()[0]
    if len( ii ):
        i  = max( n, ii.max() + 1 )
        w2 = shape[axes[i-1]+1:].prod() * dtype.itemsize
    s0 = s[ :n]
    s1 = s[n: ]
    n0 = s[ :n].prod()
    n1 = s[n:i].prod()
    n2 = s[i: ].prod()
    v = numpy.empty( ( n1, n2 ), dtype )
    for j in xrange( n0 ):
        print j, n0
        offset = numpy.sum( w1 * ( j / w0 % s0 ) )
        for k in xrange( n1 ):
            fd_in.seek( offset + k * w2, 0 )
            v[k,:] = numpy.fromfile( fd_in, dtype, n2 )
        v.reshape( s1 ).transpose( T ).tofile( fd_out )
    return

def compile( compiler, object, source ):
    """An alternative to Make that uses state files"""
    import os, sys, glob, difflib
    statedir = os.path.join( os.path.dirname( object ), '.state' )
    if not os.path.isdir( statedir ):
        os.mkdir( statedir )
    statefile = os.path.join( statedir, os.path.basename( object ) )
    command = compiler + [ object ] + [ f for f in source if f ]
    state = [ ' '.join( command ) + '\n' ]
    for f in source:
        if f: state += open( f, 'r' ).readlines()
    compile = True
    if os.path.isfile( object ):
        try:
            oldstate = open( statefile ).readlines()
            diff = ''.join( difflib.unified_diff( oldstate, state, n=0 ) )
            if diff: print diff
            else: compile = False
        except: pass
    if compile:
        try: os.unlink( statefile )
        except: pass
        print ' '.join( command )
        if os.system( ' '.join( command ) ):
            sys.exit( 'Compile error' )
        open( statefile, 'w' ).writelines( state )
        for pat in [ '*.o', '*.mod', '*.ipo', '*.il', '*.stb' ]:
            for f in glob.glob( pat ):
                os.unlink( f )
    return compile

def install_path():
    """Install path file in site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os, sys
    f   = os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
    pth = os.path.join( get_python_lib(), f )
    dir = os.path.dirname( os.path.dirname( os.path.realpath( __file__ ) ) )
    print 'Installing ' + pth
    print 'for path ' + dir
    try: open( pth, 'w' ).write( dir )
    except: sys.exit( 'You do not have write permission for this Python install' )
    return

def uninstall_path():
    """Remove path file from site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os
    f = os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
    pth = os.path.join( get_python_lib(), f )
    print 'Removing ' + pth
    if os.path.isfile( pth ):
        try: os.unlink( pth )
        except: sys.exit( 'You do not have write permission for this Python install' )
    return

def install():
    """Copy package to site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os, sys, shutil
    src = os.path.dirname( os.path.realpath( __file__ ) )
    f   = os.path.basename( os.path.dirname( __file__ ) )
    dst = os.path.join( get_python_lib(), f )
    print 'Installing ' + dst
    print 'From ' + src
    try: shutil.rmtree( dst )
    except: pass
    try: shutil.copytree( src, dst )
    except: sys.exit( 'You do not have write permission for this Python install' )
    return

def uninstall():
    """Remove package from site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os, shutil
    f   = os.path.basename( os.path.dirname( __file__ ) )
    dst = os.path.join( get_python_lib(), f )
    print 'Removing ' + dst
    if os.path.isdir( dst ):
        try: shutil.rmtree( dst )
        except: sys.exit( 'You do not have write permission for this Python install' )
    return

