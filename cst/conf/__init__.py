"""
Configuration modules
"""

try:
    from . import site
except ImportError:
    import os
    f = os.path.join(os.path.dirname(__file__), 'site.py')
    open(f, 'a').write('')
    del(os, f)
    from . import site

from . import site, default, cvms
site, default, cvms

