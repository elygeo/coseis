#!/usr/bin/env python
"""
Read configuration files
"""

def configure( machine=None ):
    """Read configuration files"""
    import os
    import util
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    cfg = { 'machine':'default' }
    util.load( 'conf/default/conf.py', cfg )
    if not machine and os.path.isfile( 'machine' ):
        machine = file( 'machine', 'r' ).read().strip()
    if machine:
        util.load( 'conf/' + machine + '/conf.py', cfg )
        cfg['machine'] = machine
    file( 'machine', 'w' ).write( cfg['machine'] )
    f = 'conf/' + cfg['machine'] + '/templates'
    if not os.path.isdir( f ):
        f = 'conf/default/templates'
    cfg['templates'] = [ 'conf/common/templates', f ]
    os.chdir( cwd )
    return cfg

if __name__ == '__main__':
    """Test configuration"""
    import os, sys
    c = configure( *sys.argv[1:] )
    print c['notes']
    for k, v in c.iteritems():
        if k != 'notes':
            print '%s = %r' % ( k, v )

