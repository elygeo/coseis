"""
Computational Seismology Tools
"""
import os
path = os.path.dirname( __file__ )
import util, conf
import coord, signal, swab
import data, vm1d, gocad, cvmh
import source, egmm
import viz, plt, mlab
import sord, cvm

try:
    from conf import site
except( ImportError ):
    pass

try:
    import rspectra
except( ImportError ):
    pass

def _build():
    cwd = os.getcwd()
    os.chdir( path )
    if not os.path.isfile( 'rspectra.so' ):
        print( '\nBuilding rspectra' )
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

