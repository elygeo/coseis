#!/usr/bin/env python
"""
Read configuration files
"""
import os, sys, util

def configure( save=False, machine=None ):
    """
    Read configuration files
    """
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( path )
    d = {}
    exec open( 'default-cfg.py' ) in d
    if not machine and os.path.isfile( 'machine' ):
        machine = open( 'machine' ).read().strip()
    if machine:
        path = os.path.join( 'conf', machine, 'conf.py' )
        exec open( path ) in d
        d['machine'] = machine
        if save:
            open( 'machine', 'w' ).write( machine )
    util.prune( d, '(^_)|(^.$)' )
    os.chdir( cwd )
    return d

# Set configuration from command line.
# Available configurations are in the 'conf' directory.
if __name__ == '__main__':
    cfg = configure( True, *sys.argv[1:2] )
    print( cfg['notes'] )
    for k in sorted( cfg.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cfg[k]) )

