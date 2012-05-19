"""
Configuration modules
"""

import os, sys

# create empty site.py if it does not exist
open(os.path.join(os.path.dirname(__file__), 'site.py'), 'a')

from . import default, site

# merge site attributes
for k in dir(site):
    getattr(default, k)
    v = getattr(site, k)
    setattr(default, k, v)

# merge machine attributes
if default.machine:
    machine = __name__ + '.' + default.machine
    __import__(machine)
    machine = sys.modules[machine]
    default.__doc__ = machine.__doc__
    for k in dir(machine):
        getattr(default, k)
        v = getattr(machine, k)
        setattr(default, k, v)
    if hasattr(machine, '__path__'):
        default.templates = machine.__path__[0]

# merge fortran flags
if default.fortran_serial in default.fortran_flags:
    default.fortran_flags = default.fortran_flags[default.fortran_serial]

from . import cvms

# merge into cvms
for k in dir(default):
    if not hasattr(cvms, k):
        v = getattr(default, k)
        setattr(cvms, k, v)
if hasattr(cvms, 'cvms_opts'):
    for k in cvms.cvms_opts:
        v = cvms.cvms_opts[k]
        setattr(cvms, k, v)

del(os, sys, k, v)

