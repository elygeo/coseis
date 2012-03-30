#!/usr/bin/env python
import numpy as np
from distutils.core import setup
from distutils.extension import Extension
ext = Extension(
    'cst/interpolate',
    ['cst/interpolate.c'],
    include_dirs = [np.get_include()]
)
setup(ext_modules = [ext])

