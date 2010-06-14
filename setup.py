#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys, getopt
if __name__ != '__main__':
    sys.exit( 'Error, not a module: %s' % __file__ )
import cst

opts, args = getopt.getopt( sys.argv[1:], '', 'machine=' )
if opts:
    machine = opts[0][1]
    cf = cst.conf.configure( 'default', machine, save_site=True )[0]
    print( cf.notes )
    cf = cf.__dict__
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )
else:
    path = os.path.dirname( os.path.realpath( __file__ ) )
    for target in args:
        if target == 'build':
            cst.tools._build()
            cst.sord._build()
            cst.cvm._build()
        elif target == 'path':
            cst.conf.install_path( path )
        elif target == 'unpath':
            cst.conf.uninstall_path( path )
        elif target == 'install':
            path = os.path.join( path, 'cst' )
            cst.conf.install( path )
        elif target == 'uninstall':
            path = os.path.join( path, 'cst' )
            cst.conf.uninstall( path )
        else:
            sys.exit( 'Unknown target' )

