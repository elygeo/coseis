#!/usr/bin/env python
"""
SCEC Community Velocity Model

http://www.data.scec.org/3Dvelocity/Version4.tar.gz
"""
import os, sys, re, glob, shutil, tarfile
import conf
from conf import launch
from tools import util

path = os.path.realpath( os.path.dirname( __file__ ) )
repo = os.path.expanduser( '~/data-repo' )
repo = os.path.join( path, 'data' )

def build( mode=None, optimize=None ):
    """
    Build CVM code.
    """
    cf = conf.configure( 'cvm' )[0]
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'asm'

    # unpack data
    f = os.path.join( path, 'bin' )
    g = os.path.join( path, 'bin', 'cvm4' )
    h = os.path.join( repo, 'cvm4.tgz' )
    if not os.path.exists( f ):
        os.mkdir( f )
    if not os.path.exists( g ):
        tarfile.open( h, 'r:gz' ).extractall( f )

    # find hard-coded array sizes, save it for later
    f = os.path.join( path, 'src', 'newin.h' )
    g = os.path.join( path, 'bin', 'cvm4', 'ibig' )
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
        source = 'iotxt.f', 'cvm4.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', 'cvm4', 'cvm4-a' + opt )
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    if 's' in mode:
        source = 'iobin.f', 'cvm4.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', 'cvm4', 'cvm4-s' + opt )
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi:
        source = 'iompi.f', 'cvm4.f'
        for opt in optimize:
            object_ = os.path.join( path, 'bin', 'cvm4', 'cvm4-m' + opt )
            compiler = cf.fortran_mpi + cf.fortran_flags[opt] + ('-o',)
            util.make( compiler, object_, source )
    os.chdir( cwd )
    return

def stage( inputs={}, **kwargs ):
    """
    Stage job
    """

    print( 'CVM setup' )

    # update inputs
    inputs = inputs.copy()
    inputs.update( kwargs )

    # configure
    job, inputs = conf.configure( module='cvm', **inputs )
    if inputs:
        sys.exit( 'Unknown parameter: %s' % inputs )
    if not job.mode:
        job.mode = 's'
        if job.nproc > 1:
            job.mode = 'm'
    job.rundir = os.path.join( job.workdir, job.name )
    job.command = os.path.join( '.', job.name + '-' + job.mode + job.optimize )
    job = conf.prepare( job )

    # check minimum processors needed for compiled memory size
    f = os.path.join( os.path.dirname( __file__ ), 'bin', job.name, 'ibig' )
    ibig = int( open( f, 'r' ).read() )
    #import pprint
    #pprint.pprint( job.__dict__ )
    minproc = int( job.nsample / ibig )
    if job.nsample % ibig != 0:
        minproc += 1
    if minproc > job.nproc:
        sys.exit( 'Need at lease %s processors for this mesh size' % minproc )

    # create run directory
    path = os.path.realpath( os.path.dirname( __file__ ) )
    f = os.path.join( path, 'bin', job.name )
    if job.force == True and os.path.isdir( job.rundir ):
        shutil.rmtree( job.rundir )
    if not job.reuse or not os.path.exists( job.rundir ):
        shutil.copytree( f, job.rundir )
    else:
        for f in (
            job.lon_file, job.lat_file, job.dep_file,
            job.rho_file, job.vp_file, job.vs_file
        ):
            ff = os.path.join( job.rundir, f )
            if os.path.exists( ff ):
                os.remove( ff )

    # process templates
    conf.skeleton( job, new=False )

    # save configuration
    f = os.path.join( job.rundir, 'conf.py' )
    util.save( f, job.__dict__ )

    return job

