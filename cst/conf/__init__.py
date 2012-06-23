"""
Configuration modules
"""

from . import default, cvms

try:
    from . import site
except ImportError:
    import os
    f = os.path.join(os.path.dirname(__file__), 'site.py')
    open(f, 'a').write('machine = %r' % default.machine)
    del(os, f)
    from . import site

site, default, cvms

