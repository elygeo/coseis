#!/usr/bin/env python
"""
SCEC Community Velocity Model
"""
import os, sys, re, shutil, urllib, tarfile
from .. import conf
from ..conf import launch
from ..tools import util

url = 'http://www.data.scec.org/3Dvelocity/Version4.tar.gz'
url = 'http://earth.usc.edu/~gely/coseis/cvm4.tgz'
path = os.path.realpath( os.path.dirname( __file__ ) )
repo = os.path.realpath( os.path.join( path, '..', 'data' ) )
tarball = os.path.join( repo, os.path.basename( url ) )
srcfiles = [
    'version4.0.f', 'in.h',
    'borehole.h', 'dim2.h', 'dim8.h', 'genpro.h',
    'genprod.h', 'innum.h', 'ivsurface.h', 'ivsurfaced.h',
    'labup.h', 'mantle.h', 'mantled.h', 'moho1.h',
    'names.h', 'regional.h', 'regionald.h', 'sgeo.h',
    'sgeod.h', 'soil1.h', 'surface.h', 'surfaced.h',
    'wtbh1.h', 'wtbh1d.h', 'wtbh2.h', 'wtbh3.h',
]
datafiles = [
    '3D.out', 'bmod_edge', 'boreholes', 'eh.modPS',
    'impva.edge', 'ivmod.edge', 'lab_geo2_geology', 'moho_sur',
    'salton_base.sur', 'smb1_edge', 'soil.pgm', 'soil_generic',
] 
for surf in [
    'b1__', 'b2__', 'b3__', 'b4__', 'b5__', 'ku1_', 'ku2_', 'ku3_', 
    'ku4_', 'ku5_', 'ku8_', 'laba', 'lamo', 'lare', 'laup', 'nsbb',
    'pu1_', 'pu2A', 'pu2B', 'pu3_', 'pu9_', 'q12b', 'q12x', 'q12y',
    'q12z', 'qps1', 'qps2', 'qps5', 'qps6', 'sbb2', 'sbb_', 'sbmi',
    'sbmo', 'sgba', 'sgmo', 'sgre', 'sku2', 'smb2', 'smb3', 'smb9',
    'smm1', 'smm2', 'smr1', 'smr2', 'sp9b', 'spu1', 'spu9', 'st4b',
    'st4s', 'ste2', 'te1_', 'te2_', 'te3_', 'te4_', 'te5_', 'te6A',
    'te6B', 'te7_', 'te8_', 'tj1_', 'tj2_', 'tj3_', 'tj4_', 'tj5_',
    'tsq1', 'tsq2', 'tsq3', 'tsq4', 'tsq5', 'tsq7', 'tsq9', 'tv1_',
    'tv2_', 'tv3_', 'tv5_', 'tv9_',
]:
    datafiles += [ surf + '_sur2', surf + '_edge' ]


def build( mode=None, optimize=None ):
    """
    Build CVM code.
    """

    # configure
    cf = conf.configure( 'cvm' )[0]
    if not optimize:
        optimize = cf.optimize
    if not mode:
        mode = cf.mode
    if not mode:
        mode = 'asm'

    # download model
    if not os.path.exists( tarball ):
        if not os.path.exists( repo ):
            os.makedirs( repo )
        print( 'Downloading %s' % url )
        urllib.urlretrieve( url, tarball )

    # build directory
    cwd = os.getcwd()
    os.chdir( path )
    if not os.path.exists( 'build' ):
        os.makedirs( 'build' )
        fh = tarfile.open( tarball, 'r:gz' )
        members = [ fh.getmember( s ) for s in srcfiles ]
        fh.extractall( 'build', members )
        if os.system( 'patch -p0 < cvm4.patch' ):
            sys.exit( 'Error patching CVM' )
    os.chdir( 'build' )

    # find array sizes, save it for later
    for line in file( 'in.h', 'r' ).readlines():
        if line[0] != ' ':
            continue
        pat = re.compile( 'ibig *= *([0-9]*)' ).search( line )
        if pat:
            ibig = pat.groups()[0]
    open( 'ibig', 'w' ).write( str( ibig ) )

    # compile ascii, binary, and MPI versions
    if 'a' in mode:
        source = 'iotxt.f', 'version4.0.f'
        for opt in optimize:
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            object_ = 'cvm4-a' + opt
            util.make( compiler, object_, source )
    if 's' in mode:
        source = 'iobin.f', 'version4.0.f'
        for opt in optimize:
            compiler = cf.fortran_serial + cf.fortran_flags[opt] + ('-o',)
            object_ = 'cvm4-s' + opt
            util.make( compiler, object_, source )
    if 'm' in mode and cf.fortran_mpi:
        source = 'iompi.f', 'version4.0.f'
        for opt in optimize:
            object_ = 'cvm4-m' + opt
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
    job.rundir = os.path.join( job.workdir, 'cvm4' )
    job.command = os.path.join( '.', 'cvm4' + '-' + job.mode + job.optimize )
    job = conf.prepare( job )

    # check minimum processors needed for compiled memory size
    f = os.path.join( path, 'build', 'ibig' )
    ibig = int( open( f, 'r' ).read() )
    minproc = int( job.nsample / ibig )
    if job.nsample % ibig != 0:
        minproc += 1
    if minproc > job.nproc:
        sys.exit( 'Need at lease %s processors for this mesh size' % minproc )

    # create run directory
    if job.force == True and os.path.isdir( job.rundir ):
        shutil.rmtree( job.rundir )
    if not job.reuse or not os.path.exists( job.rundir ):
        files = os.path.join( path, 'build', job.command ),
        conf.skeleton( job, files )
        fh = tarfile.open( tarball, 'r:gz' )
        members = [ fh.getmember( s ) for s in datafiles ]
        fh.extractall( 'build', members )
    else:
        for f in (
            job.lon_file, job.lat_file, job.dep_file,
            job.rho_file, job.vp_file, job.vs_file
        ):
            ff = os.path.join( job.rundir, f )
            if os.path.exists( ff ):
                os.remove( ff )

    # save configuration
    f = os.path.join( job.rundir, 'conf.py' )
    util.save( f, job.__dict__ )

    return job

