"""
Computational Seismology Tools
"""

from . import conf, util, viz, plt, mlab
from . import interpolate, coord, signal, source, egmm, waveform, kostrov
from . import data, scedc, vm1d, gocad, cvmh, cfm, sord, cvms

class obj(object):
    def __getitem__(self, item):
        return item
s_ = obj()

