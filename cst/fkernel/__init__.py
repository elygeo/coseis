#!/usr/bin/env python
"""
Frechet kernel computation
"""
import os
from ..conf import launch

path = os.path.dirname( os.path.realpath( __file__ ) )

def _build( optimize=None ):
    import cst
    cf = cst.conf.configure()[0]
    if not optimize:
        optimize = cf.optimize
    mode = cf.mode
    if not mode:
        mode = 'm'
    source = 'signal.f90', 'ker_utils.f90', 'cpt_ker.f90'
    new = False
    cwd = os.getcwd()
    bld = os.path.join( os.path.dirname( path ), 'build' ) + os.sep
    os.chdir( path )
    if not os.path.isdir( bld ):
        os.mkdir( bld )
    if 'm' in mode and cf.fortran_mpi[0]:
        for opt in optimize:
            object_ = bld + 'cpt_ker-m' + opt
            fflags = cf.fortran_flags['f'], cf.fortran_flags[opt]
            compiler = (cf.fortran_mpi,) + fflags + ('-o',)
            new |= cst.conf.make( compiler, object_, source )
    if new:
        cst._archive()
    os.chdir( cwd )
    return


