#!/usr/bin/env python
import os, sys
import coseis as cst

def build( target, path ):
    path = os.path.realpath( os.path.expanduser( path ) )
    if target == 'all':
        cst.tools.build()
        cst.sord.build()
        cst.cvm.build()
        cst.conf.install_path( os.path.dirname( path ) )
    elif target == 'tools':
        cst.tools.build()
    elif target == 'sord':
        cst.sord.build()
    elif target == 'cvm':
        cst.cvm.build()
    elif target == 'path':
        cst.conf.install_path( os.path.dirname( path ) )
    elif target == 'unpath':
        cst.conf.uninstall_path( os.path.dirname( path ) )
    elif target == 'install':
        cst.conf.install( path )
    elif target == 'uninstall':
        cst.conf.uninstall( path )
    else:
        sys.exit( 'Unknown target' )

if __name__ == '__main__':
    target = sys.argv[-1]
    path = os.path.dirname( __file__ ) 
    build( target, path )

