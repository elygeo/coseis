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

def destination_list():
    """
    Get user input to pick destinations from list.
    """
    path = os.path.join( os.path.dirname( __file__ ), 'destinations' )
    destinations = [ a.strip() for a in open( path, 'r' ).readlines() ]
    list = []
    for i, a in enumerate( destinations ):
        print( '%3s  %s' % ( i+1, a.strip('#') ) )
        if a[0] is not '#':
            list += [ i+1 ]
    if   mode == '-p':
        list = [ len( destinations ) ]
    elif mode == '-g':
        list = []
    input = raw_input( '\nDestinations %r: ' % list ).split(',')
    if input[0]:
        list = [ int(i) for i in input ]
    out = []
    for i in list:
        a = destinations[i-1].strip('#').split(' ')
        rsh = ' '.join( a[:-1] )
        path = a[-1]
        out += [ (rsh, path) ]
    return out

# Command line
if __name__ == '__main__':
    import sys, getopt
    opts, args = getopt.getopt( sys.argv[1:], 'dpg' )
    mode = '-d'
    if opts:
        mode = opts[-1][0]
    if mode == '-d':
        print( deploy.__doc__ )
    elif mode == '-p':
        print( publish.__doc__ )
    elif mode == '-g':
        print( get.__doc__ )
    for rsh, path in destination_list()
        if mode == '-d':
            deploy( rsh, path, args )
        elif mode == '-p':
            publish( rsh, path )
        elif mode == '-g':
            get( rsh, path, args )

