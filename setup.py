#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys
if __name__ != '__main__':
    sys.exit( 'Error, trying to import non-module: %s' % __file__ )

def build( targets, path ):
    path = os.path.realpath( os.path.expanduser( path ) )
    for targ in targets:
        if targ == 'build':
            tools._build()
            sord._build()
            cvm._build()
        elif targ == 'path':
            conf.install_path( os.path.dirname( path ) )
        elif targ == 'unpath':
            conf.uninstall_path( os.path.dirname( path ) )
        elif targ == 'install':
            conf.install( path )
        elif targ == 'uninstall':
            conf.uninstall( path )
        else:
            sys.exit( 'Unknown target' )
    return

import cst
path = os.path.dirname( __file__ )
for target in sys.argv[1:]:
    build( target, path )

