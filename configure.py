#!/usr/bin/env python
"""
Read configuration files
"""

def configure( save=False, machine=None ):
    """Read configuration files"""
    import os
    import util
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    cfg = util.load( 'default-cfg.py' )
    if not machine and os.path.isfile( 'machine' ):
        machine = file( 'machine', 'r' ).read().strip()
    if machine:
        util.load( 'conf/' + machine + '/conf.py', cfg )
        cfg['machine'] = machine
        if save:
            file( 'machine', 'w' ).write( cfg['machine'] )
    os.chdir( cwd )
    return cfg

if __name__ == '__main__':
    """Set configuration"""
    import os, sys
    cfg = configure( True, *sys.argv[1:2] )
    print cfg['notes']
    for k, v in cfg.iteritems():
        if k != 'notes':
            print '%s = %r' % ( k, v )

