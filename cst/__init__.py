"""
Computational Seismology Tools
"""
from __future__ import division, print_function
import os, subprocess, shlex
path = os.path.dirname(__file__)
from . import util, conf
from . import coord, signal
from . import data, scedc, vm1d, gocad, cvmh
from . import source, egmm, waveform, kostrov
from . import viz, plt, mlab
from . import sord, cvms, fkernel

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
    os.chdir(path)
    if not os.path.isfile('rspectra.so'):
        print('\nBuilding rspectra')
        cmd1 = ['f2py'] + shlex.split(cf.f2py_flags) + ['-c', '-m', 'rspectra', 'rspectra.f90']
        cmd2 = ['f2py'] + shlex.split(cf.f2py_flags) + ['-c', '--fcompiler=gnu95', '-m', 'rspectra', 'rspectra.f90']
        try:
            subprocess.check_call(cmd1)
        except:
            subprocess.check_call(cmd2)
    os.chdir(cwd)

def _archive():
   try:
        import git, tarfile, gzip
        repo = git.Repo(path)
   except:
        print('Warning: Source code not archived. To enable, use')
        print('Git versioned source code and install GitPython.')
   else:
        f = os.path.join(path, 'build', 'coseis.tgz')
        repo.archive(open('tmp.tar', 'w'), prefix='coseis/')
        tar = tarfile.open('tmp.tar', 'a')
        open('tmp.log', 'w').write(repo.git.log())
        tar.add('tmp.log', 'coseis/changelog')
        tar.close()
        tar = open('tmp.tar', 'rb').read()
        os.remove('tmp.tar')
        os.remove('tmp.log')
        gzip.open(f, 'wb').write(tar)

