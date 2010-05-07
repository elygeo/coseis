#!/usr/bin/env python
"""
Set and display SORD configuration
"""
import sys, conf

# Continue if not imported
if __name__ == '__main__':
    cf = conf.configure( 'sord', *sys.argv[1:2], save=True )[0]
    print( cf['notes'] )
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )

