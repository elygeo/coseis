from .nics_kraken import __doc__
from .nics_kraken import *

fortran_flags = {
    'f': '-Mdclchk',
    'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
    't': '-Ktrap=fp -Mbounds',
    'p': '-pg -Mprof=func',
    'O': '-fast',
    '8': '-Mr8',
}

cvms_opts = dict(
    fortran_flags = {
        'g': '-Ktrap=fp -Mbounds -Mchkptr -g',
        'O': '-fast',
    },
)

