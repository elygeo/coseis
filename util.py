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

def save( filename, d, expandlist=[] ):
    """Write variables from a dict into a Python source file"""
    import sys
    f = file( filename, 'w' )
    for k in sorted( d.keys() ):
        if k[0] is not '_' and type(d[k]) is not type(sys) and k not in expandlist:
            f.write( '%s = %r\n' % ( k, d[k] ) )
    for k in expandlist:
        f.write( k + ' = [\n' )
        for line in d[k]:
            f.write( repr( line ) + ',\n' )
        f.write( ']\n' )
    f.close()
    return

def indices( ii, mm ):
    """Fill in slice index notation"""
    n = len( mm )
    if len( ii ) == 0:
        ii = n * [ 0 ]
    elif len( ii ) != n:
        sys.exit( 'error in indices' )
    ii = ii[:]
    for i in range( n ):
        if ii[i] == 0:
            ii[i] = [ 1, -1, 1 ]
        elif type( ii[i] ) == int:
            ii[i] = [ ii[i], ii[i], 1 ]
        else:
            ii[i] = list( ii[i] )
        if len( ii[i] ) == 2:
            ii[i] = ii[i] + [ 1 ]
        for j in range( 3 ):
            if ii[i][j] < 1:
                ii[i][j] = ii[i][j] + mm[i] + 1
        ii[i] = tuple( ii[i] )
    return ii

def ndread( filename, mm=None, ii=[], endian='=' ):
    """Read n-dimensional slice from binary file"""
    import numpy
    fd = file( filename, 'rb' )
    dtype = numpy.dtype( numpy.float32 ).newbyteorder( endian )
    if not mm: return numpy.fromfile( fd, dtype )
    elif type( mm ) == int: mm = [ mm ]
    else: mm = list( mm )
    ndim = len( mm )
    ii = indices( ii, mm )
    i0 = [ ii[i][0] - 1             for i in range( ndim ) ]
    nn = [ ii[i][1] - ii[i][0] + 1  for i in range( ndim ) ]
    for i in xrange( ndim-1, 0, -1 ):
        if mm[i-1] == nn[i-1]:
            i0[i-1] = mm[i-1] * i0[i]; del i0[i]
            nn[i-1] = mm[i-1] * nn[i]; del nn[i]
            mm[i-1] = mm[i-1] * mm[i]; del mm[i]
    nb = dtype.itemsize
    i0 = ( i0 + [ 0, 0 ] )[:3]
    nn = ( nn + [ 1, 1 ] )[:3]
    mm = ( mm + [ 1, 1 ] )[:3]
    f = numpy.empty( nn[::-1], dtype )
    for l in xrange( nn[2] ):
        for k in xrange( nn[1] ):
            i = i0[0] + mm[0] * ( i0[1] + k + mm[1] * ( i0[2] + l ) )
            fd.seek( nb * i, 0 )
            f[l,k,:] = numpy.fromfile( fd, dtype, nn[0] )
    nn = [ ii[i][1] - ii[i][0] + 1  for i in range( ndim ) ]
    return f.reshape( nn[::-1] ).T

def compile( compiler, object, source ):
    """An alternative to Make that uses state files"""
    import os, sys, glob, difflib
    #import subprocess
    statedir = os.path.dirname( object ) + os.sep + '.state'
    if not os.path.isdir( statedir ):
        os.mkdir( statedir )
    statefile = statedir + os.sep + os.path.basename( object )
    command = compiler + [ object ] + [ f for f in source if f ]
    state = [ ' '.join( command ) + '\n' ]
    for f in source:
        if f: state += file( f, 'r' ).readlines()
    compile = True
    if os.path.isfile( object ):
        try:
            oldstate = file( statefile ).readlines()
            diff = ''.join( difflib.unified_diff( oldstate, state, n=0 ) )
            if diff: print diff
            else: compile = False
        except: pass
    if compile:
        try: os.unlink( statefile )
        except: pass
        print ' '.join( command )
        #if subprocess.call( command ):
        if os.system( ' '.join( command ) ):
            sys.exit( 'Compile error' )
        file( statefile, 'w' ).writelines( state )
        for pat in [ '*.o', '*.mod', '*.ipo', '*.il', '*.stb' ]:
            for f in glob.glob( pat ):
                os.unlink( f )
    return compile

def install_path():
    """Install path file in site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os
    pth = get_python_lib() + os.sep + os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
    dir = os.path.dirname( os.path.dirname( os.path.realpath( __file__ ) ) )
    print 'Installing ' + pth
    print 'for path ' + dir
    try: file( pth, 'w' ).write( dir )
    except: sys.exit( 'You do not have write permission for this Python install' )
    return

def uninstall_path():
    """Remove path file from site-packages directory"""
    from distutils.sysconfig import get_python_lib
    import os
    pth = get_python_lib() + os.sep + os.path.basename( os.path.dirname( __file__ ) ) + '.pth'
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
    dst = get_python_lib() + os.sep + os.path.basename( os.path.dirname( __file__ ) )
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
    dst = get_python_lib() + os.sep + os.path.basename( os.path.dirname( __file__ ) )
    print 'Removing ' + dst
    if os.path.isdir( dst ):
        try: shutil.rmtree( dst )
        except: sys.exit( 'You do not have write permission for this Python install' )
    return

