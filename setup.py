#!/usr/bin/env python
"""
Build SORD binaries and documentation
"""
import os, sys, getopt
import numpy as np
import conf
from util import util

def build( mode=None, optimize=None, dtype=None ):
    """
    Build SORD code.
    """
    cf = conf.configure( 'sord' )[0]
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'sm'
    if not dtype:
        dtype = cf.dtype
    base = (
        'globals.f90',
        'diffcn.f90',
        'diffnc.f90',
        'hourglass.f90',
        'bc.f90',
        'surfnormals.f90',
        'util.f90',
        'fio.f90',
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
    dtype = np.dtype( dtype ).str
    dsize = dtype[-1]
    if 's' in mode:
        source = base + ('serial.f90',) + common
        for opt in optimize:
            object_ = os.path.join( '..', 'bin', 'sord-s' + opt + dsize )
            fflags = cf.fortran_flags['f'] + cf.fortran_flags[opt]
            if dtype != cf.dtype_f:
                fflags = fflags + cf.fortran_flags[dsize]
            compiler = cf.fortran_serial + fflags + ('-o',)
            new |= util.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi[0]:
        if cf.machine == 'usc-hpc':
            source = base + ('mpi_hpcc.f90',) + common
        else:
            source = base + ('mpi.f90',) + common
        for opt in optimize:
            object_ = os.path.join( '..', 'bin', 'sord-m' + opt + dsize )
            fflags = cf.fortran_flags['f'] + cf.fortran_flags[opt]
            if dtype != cf.dtype_f:
                fflags = fflags + cf.fortran_flags[dsize]
            compiler = cf.fortran_mpi + fflags + ('-o',)
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

def rspec():
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( os.path.join( path, 'util' ) )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

def command_line():
    """
    Process command line options.
    """
    opts, args = getopt.getopt( sys.argv[1:], 'smgtpO8' )
    mode = None
    optimize = None
    dtype = None
    for o in opts:
        o = o[0][1:]
        if o in 'sm':
            mode = o
        elif o in 'gtpO':
            optimize = o
        elif o in '8':
            dtype = 'f' + o
    if not args:
        build( mode, optimize, dtype )
    else:
        if args[0] == 'path':
            util.install_path( __file__ )
        elif args[0] == 'unpath':
            util.uninstall_path( __file__ )
        elif args[0] == 'install':
            util.install( __file__ )
        elif args[0] == 'uninstall':
            util.uninstall( __file__ )
        elif args[0] == 'rspec':
            rspec()
        else:
            sys.exit( 'Error: unknown option: %r' % sys.argv[1] )

if __name__ == '__main__':
    command_line()

