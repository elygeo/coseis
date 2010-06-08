#!/usr/bin/env python
"""
Set and display configuration
"""
import sys, conf

# Continue if not imported
if __name__ == '__main__':
    cf = conf.configure( 'default', *sys.argv[1:2], save_machine=True )[0]
    print( cf.notes )
    cf = cf.__dict__
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )

