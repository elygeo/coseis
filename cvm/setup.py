#!/usr/bin/env python
"""
Build SCEC CVM
"""
import os, sys, re, getopt, tarfile
import conf
from util import util

path = os.path.realpath( os.path.dirname( __file__ ) )
repo = os.path.expanduser( '~/data-repo' )
repo = os.path.join( path, 'data' )

def build( version='4', mode=None, optimize=None ):
    """
    Build CVM code.
    """
    vm = 'cvm' + version
    cf = conf.configure( 'cvm' )[0]
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'asm'

    # unpack data
    f = os.path.join( path, 'bin' )
    g = os.path.join( path, 'bin', vm )
    h = os.path.join( repo, vm + '.tgz' )
    if not os.path.exists( f ):
        os.mkdir( f )
    if not os.path.exists( g ):
        tarfile.open( h, 'r:gz' ).extractall( f )

    # find hard-coded array sizes, save it for later
    f = os.path.join( path, vm, 'newin.h' )
    g = os.path.join( path, 'bin', vm, 'ibig' )
    for line in file( f, 'r' ).readlines():
        if line[0] != ' ':
            continue
        pat = re.compile( 'ibig *= *([0-9]*)' ).search( line )
        if pat:
            ibig = pat.groups()[0]
    open( g, 'w' ).write( str( ibig ) )

    # compile ascii, binary, and MPI versions
    cwd = os.getcwd()
    os.chdir( os.path.join( path, vm ) )
    if 'a' in mode:
        source = 'iotxt.f', vm + '.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', vm, vm + '-a' + opt )
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    if 's' in mode:
        source = 'iobin.f', vm + '.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', vm, vm + '-s' + opt )
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi:
        source = 'iompi.f', vm + '.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', vm, vm + '-m' + opt )
            compiler = cf.fortran_mpi + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    os.chdir( cwd )

    return

def command_line():
    """
    Process command line options.
    """
    opts, args = getopt.getopt( sys.argv[1:], '34asmgO' )
    mode = None
    optimize = None
    version = '4'
    for o in opts:
        o = o[0][1:]
        if o in 'asm':
            mode = o
        elif o in '34':
            version = o
        elif o in 'gO':
            optimize = o
    if not args:
        build( version, mode, optimize )
    else:
        if args[0] == 'path':
            util.install_path( __file__ )
        elif args[0] == 'unpath':
            util.uninstall_path( __file__ )
        else:
            sys.exit( 'Error: unknown option: %r' % sys.argv[1] )

# Command line
if __name__ == '__main__':
    command_line()

