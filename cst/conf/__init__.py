"""
Configuration modules
"""

from . import default

try:
    from . import site
except ImportError:
    import os
    f = os.path.join(os.path.dirname(__file__), 'site.py')
    open(f, 'a').write('machine = %r' % default.machine)
    from . import site
    del(os, f)

site, default

