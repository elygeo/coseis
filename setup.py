#!/usr/bin/env python
"""
Build SORD binaries and documentation
"""
import os, sys, getopt
import util, configure

def build( mode=None, optimize=None ):
    """
    Build SORD code.
    """
    cf = util.namespace( configure.configure() )
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'sm'
    base = (
        'globals.f90',
        'diffcn.f90',
        'diffnc.f90',
        'hourglass.f90',
        'bc.f90',
        'surfnormals.f90',
        'util.f90',
        'frio.f90',
    )
    common = (
        'arrays.f90',
        'fieldio.f90',
        'stats.f90',
        'parameters.f90',
        'setup.f90',
        'gridgen.f90',
        'material.f90',
        'source.f90',
        'inivolstress.f90',
        'rupture.f90',
        'resample.f90',
        'checkpoint.f90',
        'timestep.f90',
        'stress.f90',
        'acceleration.f90',
        'sord.f90',
    )
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    f = os.path.join( path, 'bin' )
    if not os.path.isdir( f ):
        os.mkdir( f )
    new = False
    os.chdir( os.path.join( path, 'src' ) )
    if 's' in mode:
        source = base + ('serial.f90',) + common
        for opt in optimize:
            object_ = os.path.join( '..', 'bin', 'sord-s' + opt )
            compiler = cf.fortran_serial + cf.fortran_flags[opt]
            new |= util.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi:
        source = base + ('mpi.f90',) + common
        for opt in optimize:
            object_ = os.path.join( '..', 'bin', 'sord-m' + opt )
            compiler = cf.fortran_mpi + cf.fortran_flags[opt]
            new |= util.make( compiler, object_, source )
    os.chdir( path )
    if new:
        try:
            import bzrlib
        except ImportError:
            print( 'Warning: bzr not installed. Install bzr if you want to save a\
                copy of the source code for posterity with each run.' )
        else:
            os.system( 'bzr export sord.tgz' )
    os.chdir( cwd )
    return

def docs():
    """
    Prepare documentation.
    """
    import re
    from docutils.core import publish_string
    settings = dict(
        datestamp = '%Y-%m-%d',
        generator = True,
        strict = True,
        toc_backlinks = None,
        cloak_email_addresses = True,
        initial_header_level = 3,
        stylesheet_path = 'doc/style.css',
    )
    rst = open( 'readme.txt' ).read()
    html = publish_string( rst, writer_name='html4css1',
        settings_overrides=settings )
    html = re.sub( '<col.*>\n', '', html )
    html = re.sub( '</colgroup>', '', html )
    open( 'index.html', 'w' ).write( html )
    return

def rspec():
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( os.path.join( path, 'extras' ) )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

def command_line():
    """
    Process command line options.
    """
    opts, args = getopt.getopt( sys.argv[1:], 'smgtpO' )
    mode = None
    optimize = None
    for o in opts:
        o = o[0][1:]
        if o in 'sm':
            mode = o
        elif o in 'gtpO':
            optimize = o
    if not args:
        build( mode, optimize )
    else:
        if args[0] == 'docs':
            docs()
        elif args[0] == 'path':
            util.install_path()
        elif args[0] == 'unpath':
            util.uninstall_path()
        elif args[0] == 'install':
            util.install()
        elif args[0] == 'uninstall':
            util.uninstall()
        elif args[0] == 'rspec':
            rspec()
        else:
            sys.exit( 'Error: unknown option: %r' % sys.argv[1] )

if __name__ == '__main__':
    command_line()

