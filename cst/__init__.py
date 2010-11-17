"""
Computational Seismology Tools
"""
#from __future__ import division, absolute_import, print_function, unicode_literals
import os, subprocess, shlex
path = os.path.dirname( __file__ )
from . import util, conf
from . import coord, signal
from . import data, vm1d, gocad, cvmh
from . import source, egmm
from . import viz, plt, mlab
from . import sord, cvm, fkernel

try:
    from .conf import site
except ImportError:
    pass

try:
    from . import rspectra
except ImportError:
    pass

def _build():
    import cst
    cf = cst.conf.configure()[0]
    cwd = os.getcwd()
    os.chdir( path )
    if not os.path.isfile( 'rspectra.so' ):
        print( '\nBuilding rspectra' )
        cmd = ['f2py'] + shlex.split( cf.f2py_flags ) + ['-c', '-m', 'rspectra', 'rspectra.f90']
        subprocess.check_call( cmd )
    os.chdir( cwd )

def _archive():
   try:
        import git, tarfile, gzip
        repo = git.Repo( path )
   except:
        print( 'Warning: Source code not archived. To enable, use' )
        print( 'Git versioned source code and install GitPython.' )
   else:
        f = os.path.join( path, 'build', 'coseis.tgz' )
        repo.archive( open( 'tmp.tar', 'w' ), prefix='coseis/' )
        tar = tarfile.open( 'tmp.tar', 'a' )
        open( 'tmp.log', 'w' ).write( repo.git.log() )
        tar.add( 'tmp.log', 'coseis/changelog' )
        tar.close()
        tar = open( 'tmp.tar', 'rb' ).read()
        os.remove( 'tmp.tar' )
        os.remove( 'tmp.log' )
        gzip.open( f, 'wb' ).write( tar )

