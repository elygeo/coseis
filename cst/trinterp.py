"""
Triangular mesh interpolation
"""

try:
    from trinterp_ext import trinterp
    trinterp
except ImportError:
    import os
    from distutils.core import setup, Extension
    import numpy as np
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    incl = [np.get_include()]
    ext = [Extension('trinterp_ext', ['trinterp_ext.c'], include_dirs=incl)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)
    del(incl, ext, cwd)
    del(os, setup, Extension, np)
    from trinterp_ext import trinterp
    trinterp

