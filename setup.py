#!/usr/bin/env python
"""
Setup Coseis
"""
import os, sys, getopt, pprint
if __name__ != '__main__':
    sys.exit( 'Error, not a module: %s' % __file__ )
import cst

# command line arguments
opts, args = getopt.getopt( sys.argv[1:], 'v', ['verbose', 'machine='] )

# machine presets
machine = None
for k, v in opts:
    if k == '--machine':
        machine = os.path.basename( opts[0][1] )

# configure
cf = cst.conf.configure( None, machine, save_site=True )[0]

# verbose
if cf.verbose:
    print( cf.__doc__ )
    cf = cf.__dict__
    del cf['__doc__']
    pprint.pprint( cf )

# store package path
path = os.path.dirname( os.path.realpath( __file__ ) )

# setup target
for target in args:
    if target == 'build':
        cst.sord._build()
        cst.cvm._build()
        cst.fkernel._build()
        cst._build()
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

