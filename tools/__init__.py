#!/usr/bin/env python
"""
Computational Seismology Tools
"""
import os
import util, coord, signal, swab
import data, gocad, cvmh
import source, egmm, boore
import viz, plt, mlab
try:
    import rspectra
except( ImportError ):
    pass

def build():
    path = os.path.realpath( os.path.dirname( __file__ ) )
    cwd = os.getcwd()
    os.chdir( path )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

