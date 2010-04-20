#!/usr/bin/env python
"""
Read configuration files
"""
import os, sys, glob, shutil
from util import util

def parallel( nproc, maxcores, maxnodes ):
    """
    Find optimal parallelization for desired number of processes.

    INPUT
        nproc : number of desired processes
        maxcores : physical number of cores per node
        maxnodes : physical number of compute nodes in the system
    OUTPUT
        nodes : number of compute nodes
        ppn : number of processes per node
        cores : number of cores per node
        totalcores : total number of cores
    """
    if maxcores:
        nodes = min( maxnodes, (nproc - 1) / maxcores + 1 )
        ppn = (nproc - 1) / nodes + 1
        cores = min( maxcores, ppn )
        totalcores = nodes * maxcores
    else:
        nodes = 1
        ppn = nproc
        cores = nproc
        totalcores = nproc
    return (nodes, ppn, cores, totalcores)

def skeleton( conf, directories=(), files=(), templates=None ):
    """
    Create run directory and process script templates

    conf : dictionary of parameters
    path : destination directory
    """
    src = os.path.realpath( os.path.dirname( __file__ ) )
    path = conf['rundir']
    try:
        os.makedirs( path )
    except( OSError ):
        raise
    for f in directories:
        os.makedirs( os.path.join( path, f ) )
    for f in files:
        shutil.copy( os.path.join( src, f ), path )
    f = os.path.join( src, 'conf', conf['machine'], 'templates' ),
    if not os.path.isdir( f[0] ):
        f = os.path.join( src, 'conf', 'default', 'templates' ),
    if templates:
        f += templates,
    else:
        f += os.path.join( src, 'conf', 'common', 'templates' ),
    for d in f:
        for f in glob.glob( os.path.join( d, '*' ) ):
            ff = os.path.join( path, os.path.basename( f ) )
            out = open( f ).read() % conf
            open( ff, 'w' ).write( out )
            shutil.copymode( f, ff )
    return

def configure( save=False, machine=None ):
    """
    Read configuration files
    """
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( path )
    conf = {}
    exec open( 'conf/conf.py' ) in conf
    if not machine and os.path.isfile( 'machine' ):
        machine = open( 'machine' ).read().strip()
    if machine:
        machine = os.path.basename( machine )
        path = os.path.join( 'conf', machine, 'conf.py' )
        exec open( path ) in conf
        conf['machine'] = machine
        if save:
            open( 'machine', 'w' ).write( machine )
    if conf['fortran_flags'] == None:
        fc = conf['fortran_serial'][0]
        conf['fortran_flags'] = conf['fortran_defaults'][fc]
    del( conf['fortran_defaults'] )
    util.prune( conf, pattern='(^_)|(^.$)' )
    os.chdir( cwd )
    return conf

# Set configuration from command line.
if __name__ == '__main__':
    cf = configure( True, *sys.argv[1:2] )
    print( cf['notes'] )
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )

