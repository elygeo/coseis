#!/usr/bin/env python

# Cython extensions
import numpy as np
from distutils.core import setup
from distutils.extension import Extension
ext = Extension(
    'interpolate',
    ['interpolate.c'],
    include_dirs = [np.get_include()]
)
setup(
    ext_modules = [ext],
    script_args = ['build_ext', '--inplace'],
)

# Fortran extensions
from numpy.distutils.core import setup, Extension
ext = Extension(
    'rspectra',
    ['rspectra.f90']
)
setup(
    ext_modules = [ext],
    script_args = ['build_ext', '--inplace'],
)

