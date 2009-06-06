#!/usr/bin/env python
"""
Read configuration files
"""
import os, sys, util

def configure( save=False, machine=None ):
    """Read configuration files"""
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    cfg = util.load( 'default-cfg.py' )
    if not machine and os.path.isfile( 'machine' ):
        machine = open( 'machine', 'r' ).read().strip()
    if machine:
        util.load( os.path.join( 'conf', machine, 'conf.py' ), cfg )
        cfg['machine'] = machine
        if save:
            open( 'machine', 'w' ).write( cfg['machine'] )
    os.chdir( cwd )
    return cfg

# Set configuration
if __name__ == '__main__':
    cfg = configure( True, *sys.argv[1:2] )
    print( cfg['notes'] )
    for k in sorted( cfg.keys() ):
        if k != 'notes':
            print( '%s = %r' % ( k, cfg[k] ) )

