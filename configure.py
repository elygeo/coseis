#!/usr/bin/env python
"""
Read configuration files
"""
import os, sys
import util

def configure( save=False, machine=None ):
    """
    Read configuration files
    """
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( path )
    conf = {}
    exec open( 'conf/conf.py' ) in conf
    if not machine and os.path.isfile( 'machine' ):
        machine = open( 'machine' ).read().strip()
    if machine:
        machine = os.path.basename( machine )
        path = os.path.join( 'conf', machine, 'conf.py' )
        exec open( path ) in conf
        conf['machine'] = machine
        if save:
            open( 'machine', 'w' ).write( machine )
    util.prune( conf, pattern='(^_)|(^.$)' )
    os.chdir( cwd )
    return conf

# Set configuration from command line.
if __name__ == '__main__':
    cf = configure( True, *sys.argv[1:2] )
    print( cf['notes'] )
    for k in sorted( cf.keys() ):
        if k != 'notes':
            print( '%s = %r' % (k, cf[k]) )

