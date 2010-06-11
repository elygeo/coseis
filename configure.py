#!/usr/bin/env python
"""
Configure Coseis
"""

import sys
if __name__ != '__main__':
    sys.exit( 'Error, trying to import non-module: %s' % __file__ )

import cst
cf = cst.conf.configure( 'default', *sys.argv[1:2], save_machine=True )[0]
print( cf.notes )
cf = cf.__dict__
for k in sorted( cf.keys() ):
    if k != 'notes':
        print( '%s = %r' % (k, cf[k]) )

