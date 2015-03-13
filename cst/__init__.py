"""
Computational Seismology Tools
"""

# data repository
import os
repo = os.path.dirname(__file__)
repo = os.path.join(repo, 'repo') + os.sep
if not os.path.exists(repo):
    f = os.path.dirname(__file__)
    f = os.path.join(f, '..', '..', 'Repository')
    if os.path.exists(f):
        os.symlink('../../Repository', repo)
    else:
        os.mkdir(repo)
del(os)

# components
from . import util, viz, plt, mlab
from . import interp, coord, signal, source, srf, egmm, waveform, kostrov
from . import data, scedc, vm1d, gocad, cvmh, cfm, sord, cvms
from .bin2npy import bin2npy

# stop pyflakes errors
util, viz, plt, mlab
interp, coord, signal, source, srf, egmm, waveform, kostrov
data, scedc, vm1d, gocad, cvmh, cfm, sord, cvms

# for building slice objects
class obj(object):
    def __getitem__(self, item):
        return item
s_ = obj()
del(obj)

