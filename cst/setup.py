#!/usr/bin/env python

def build_ext_cython():
    from distutils.core import setup
    from distutils.extension import Extension
    import numpy as np
    ext = Extension(
        'interpolate',
        ['interpolate.c'],
        include_dirs = [np.get_include()]
    )
    setup(
        ext_modules = [ext],
        script_args = ['build_ext', '--inplace'],
    )

def build_ext_fortran():
    from numpy.distutils.core import setup, Extension
    import shlex
    import cst
    cf = cst.conf.configure()[0]
    ext = Extension(
        'rspectra',
        ['rspectra.f90'],
        f2py_options = ['--quiet'] + shlex.split(cf.f2py_flags),
    )
    setup(
        ext_modules = [ext],
        script_args = ['build_ext', '--inplace'],
    )

if __name__ == '__main__':
    build_ext_cython()
    build_ext_fortran()

