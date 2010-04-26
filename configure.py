#!/usr/bin/env python
"""
Set and display SORD configuration
"""
import sys, conf

# Continue if not imported
if __name__ == '__main__':
    cf = conf.configure( *sys.argv[1:2], module='sord', save=True )
    print( cf['notes'] )
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )

