#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys

if __name__ != '__main__':
    sys.exit( 'Error, trying to import non-module: %s' % __file__ )

import cst

def build( targets, path ):
    if targets == []:
        cf = cst.conf.configure( 'default', save=True )[0]
        print( cf.notes )
        cf = cf.__dict__
        for k in sorted( cf.keys() ):
            if k != 'notes':
                print( '%s = %r' % (k, cf[k]) )
    else:
        for targ in targets:
            if targ == 'build':
                cst.tools._build()
                cst.sord._build()
                cst.cvm._build()
            elif targ == 'path':
                cst.conf.install_path( os.path.dirname( path ) )
            elif targ == 'unpath':
                cst.conf.uninstall_path( os.path.dirname( path ) )
            elif targ == 'install':
                cst.conf.install( path )
            elif targ == 'uninstall':
                cst.conf.uninstall( path )
            else:
                sys.exit( 'Unknown target' )
    return

opts, args = getopt.getopt( sys.argv[1:], '', 'machine=' )
path = os.path.dirname( __file__ )
path = os.path.realpath( os.path.expanduser( path ) )
for target in sys.argv[1:]:
    build( target, path )

