#!/usr/bin/env python
"""
Computational Seismology Tools
"""
import util, coord, signal, swab
import data, vm1d, gocad, cvmh
import source, egmm
import viz, plt, mlab
import sord, cvm

try:
    import rspectra
except( ImportError ):
    pass

def _build():
    import os
    path = os.path.realpath( os.path.dirname( __file__ ) )
    cwd = os.getcwd()
    os.chdir( path )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

