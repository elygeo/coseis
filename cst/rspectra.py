"""
Response Spectra
"""

try:
    from rspectra_ext import rspectra
    rspectra
except ImportError:
    import os, shlex
    from numpy.distutils.core import setup, Extension
    from . import util
    fopt = shlex.split(util.configure().f2py_flags)
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    ext = [Extension('rspectra_ext', ['rspectra_ext.f90'], f2py_options=fopt)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)
    del(fopt, ext, cwd)
    del(os, shlex, setup, Extension, util)
    from rspectra_ext import rspectra
    rspectra

