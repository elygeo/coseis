#!/usr/bin/env python
"""
Machine configuration
"""
import os, shutil
from sord import util

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

def skeleton( conf, directories=(), files=(), new=True ):
    """
    Create run directory and process script templates

    conf : dictionary of parameters
    path : destination directory
    """
    path = os.path.realpath( os.path.dirname( __file__ ) )
    dest = conf['rundir'] + os.sep
    if new:
        try:
            os.makedirs( dest )
        except( OSError ):
            raise
    for f in directories:
        os.makedirs( dest + f )
    for f in files:
        try:
            os.link( f, dest + f )
        except:
            shutil.copy2( f, dest )
    f = os.path.join( path, conf['machine'], 'templates' )
    if not os.path.isdir( f ):
        f = os.path.join( path, 'default', 'templates' )
    f = os.path.join( path, conf['module'], 'templates' ), f
    for d in f:
        for f in os.listdir( d ):
            ff = os.path.join( path, os.path.basename( f ) )
            out = open( f ).read() % conf
            open( ff, 'w' ).write( out )
            shutil.copymode( f, ff )
    return

def configure( module=None, machine=None, save=False ):
    """
    Read configuration files
    """
    path = os.path.realpath( os.path.dirname( __file__ ) )
    conf = {}
    if module:
        f = os.path.join( path, module, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in conf
    f = os.path.join( path, 'machine' )
    if not machine and os.path.isfile( f ):
        machine = open( f ).read().strip()
    if machine:
        machine = os.path.basename( os.path.normpath( machine ) )
        f = os.path.join( path, machine, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in conf
        conf['machine'] = machine
        if save:
            f = os.path.join( path, 'machine' )
            open( f, 'w' ).write( machine )
    if module in conf:
        conf.update( conf[module] )
    if 'fortran_flags_default' in conf:
        if 'fortran_flags' not in conf:
            k = conf['fortran_serial'][0]
            conf['fortran_flags'] = conf['fortran_flags_default'][k]
        #del( conf['fortran_flags_default'] )
    util.prune( conf, pattern='(^_)|(^.$)|(^sord$)|(^cvm$)|(^fortran_flags_default$)' )
    return conf

# Test all onfigurations if run from the command line
if __name__ == '__main__':
    import pprint
    modules = None, 'sord', 'cvm'
    for module in modules:
        for machine in os.listdir('.'):
            if os.path.isdir( machine ) and machine not in modules:
                cf = configure( module, machine )
                print 80 * '-'
                print 'module: %s, machine: %s' % (module, machine)
                pprint.pprint( cf )

