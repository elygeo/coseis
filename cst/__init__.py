"""
CST: Computational Seismology Tools
"""
import os
import sys
import site

if '' in sys.path:
    sys.path.remove('')

home = os.path.dirname(__file__)
home = os.path.realpath(home)
home = os.path.dirname(home) + os.sep
repo = os.path.join(home, 'Repo') + os.sep

if sys.argv[1:] == ['setup']:
    d = site.USER_SITE
    f = os.path.join(d, 'cst.pth')
    if not os.path.exists(f):
        if not os.path.exists(d):
            print('Creating ' + d)
            os.makedirs(d)
        print('Adding to sys.path: ' + home)
        open(f, 'w').write(home)
    del(d, f)

del(os, sys, site)
