"""
Configuration modules
"""

import os
f = os.path.join(os.path.dirname(__file__), 'site.py')
if not os.path.exists(f):
    open(f, 'a').write('')
del(os, f)

from . import site, default, cvms
site, default, cvms

