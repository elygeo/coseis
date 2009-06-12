#!/usr/bin/env python
"""
Remote operations: deploy, publish, get

Reads 'destinations' file with entries like:
ssh user@host.domain:path
"""
import os

def deploy( rsh, dest, command=[] ):
    """
    Deploy code and execute remote commands.
    """
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --include=destinations --include=email --include=data --include=work --include=sord.tgz --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print( rsync )
    os.system( rsync )
    os.chdir( cwd )
    for cmd in command:
        host = dest.split(':')[0]
        path = dest.split(':')[1]
        cmd = 'cd %s; %s' % (path, cmd)
        cmd = '%s %s "bash --login -c %r"' % (rsh, host, cmd)
        print( cmd )
        os.system( cmd )
    return

def publish( rsh, dest ):
    """
    Publish web page and code repository.
    """
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --delete-excluded --include=sord.tgz --include=.bzr --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print( rsync )
    os.system( rsync )
    os.chdir( cwd )
    return

def get( rsh, path, files ):
    """
    Get remote files.
    """
    for f in files:
        src = path + '/' + f.rstrip('/')
        rsync = 'rsync -av --delete -e %r %r .' % (rsh, src)
        print( rsync )
        os.system( rsync )
    return

def pick_destinations( message=None, default=None, path=None, prompt='Destinations' ):
    """
    Read destinations file and input user picks.
    """
    if message:
        print( '\n%s\n' % message.strip() )
    if not path:
        path = os.path.join( os.path.dirname( __file__ ), 'destinations' )
    destinations = [ a.strip() for a in open( path, 'r' ).readlines() ]
    picks = []
    for i, a in enumerate( destinations ):
        print( '%3s  %s' % ( i+1, a.strip('#') ) )
        if a[0] is not '#':
            picks += [ i+1 ]
    if default is not None:
        picks = default
    input = raw_input( '\n%s %r: ' % (prompt, picks) ).split( ',' )
    if input[0]:
        picks = [ int(i) for i in input ]
    out = []
    for i in picks:
        if i < 0:
            i = len( destinations ) + i + 1
        a = destinations[i-1].strip( '#' ).split( ' ' )
        out += [ ( ' '.join( a[:-1] ), a[-1] ) ]
    return out

# Command line
if __name__ == '__main__':
    import sys, getopt
    opts, args = getopt.getopt( sys.argv[1:], 'dpg' )
    opt = '-d'
    if opts:
        opt = opts[-1][0]
    if opt == '-d':
        for rsh, path in pick_destinations( deploy.__doc__ ):
            deploy( rsh, path, args )
    elif opt == '-p':
        for rsh, path in pick_destinations( publish.__doc__, [-2,-1] ):
            publish( rsh, path )
    elif opt == '-g':
        for rsh, path in pick_destinations( get.__doc__, [] ):
            get( rsh, path, args )

