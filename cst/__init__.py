"""
Computational Seismology Tools
"""

# components
from . import conf, util, viz, plt, mlab
from . import interpolate, coord, signal, source, srf, egmm, waveform, kostrov
from . import data, scedc, vm1d, gocad, cvmh, cfm, sord, cvms

# stop pyflakes errors
conf, util, viz, plt, mlab
interpolate, coord, signal, source, egmm, waveform, kostrov
data, scedc, vm1d, gocad, cvmh, cfm, sord, cvms

# for building slice objects
class obj(object):
    def __getitem__(self, item):
        return item
s_ = obj()
del(obj)

