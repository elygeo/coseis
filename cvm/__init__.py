#!/usr/bin/env python
"""
SCEC Community Velocity Model
"""
import os, sys, re, glob, shutil
import conf
from conf import launch
from util import util, coord, data, plt, mlab, viz, swab

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

