#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys, getopt, pprint
if __name__ != '__main__':
    sys.exit( 'Error, not a module: %s' % __file__ )
import cst

opts, args = getopt.getopt( sys.argv[1:], '', 'machine=' )

if opts:
    machine = os.path.basename( opts[0][1] )
    cf = cst.conf.configure( None, machine, save_site=True )[0]
    print( cf.__doc__ )
    cf = cf.__dict__
    del cf['__doc__']
    pprint.pprint( cf )
else:
    cf = cst.conf.configure( None, None, save_site=True )[0]

path = os.path.dirname( os.path.realpath( __file__ ) )

for target in args:
    if target == 'build':
        cst._build()
        cst.sord._build()
        cst.fkernel._build()
        cst.cvm._build()
    elif target == 'test':
        import nose
        argv = ['', '--verbose', '--with-doctest', '--all-modules', '--exe']
        nose.run( argv=argv )
    elif target == 'path':
        cst.conf.install_path( path, 'coseis' )
    elif target == 'unpath':
        cst.conf.uninstall_path( path, 'coseis' )
    else:
        sys.exit( 'Unknown target' )

