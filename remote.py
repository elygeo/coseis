#!/usr/bin/env python
"""
Remote operations
"""
import os

def deploy( rsh, dest, command=[] ):
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --include=destinations --include=email --include=w --include=sord.tgz --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print rsync
    os.system( rsync )
    os.chdir( cwd )
    for cmd in command:
        host = dest.split(':')[0]
        dir = dest.split(':')[1]
        cmd = 'cd %s; %s' % ( dir, cmd )
        cmd = '%s %s "bash --login -c %r"' % ( rsh, host, cmd )
        print cmd
        os.system( cmd )
    return

def publish( rsh, dest ):
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --delete-excluded --include=sord.tgz --include=.bzr --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print rsync
    os.system( rsync )
    os.chdir( cwd )
    return

def get( rsh, rdir, rfile ):
    for f in rfile:
        src = rdir + '/' + f.rstrip('/')
        rsync = 'rsync -av --delete -e %r %r .' % ( rsh, src )
        print rsync
        os.system( rsync )
    return

if __name__ == '__main__':
    import sys, getopt
    opts, args = getopt.getopt( sys.argv[1:], 'dpg' )
    mode = '-d'
    if opts: mode = opts[-1][0]
    f = os.path.dirname( __file__ ) + os.sep + 'destinations'
    destinations = [ a.strip() for a in open( f, 'r' ).readlines() ]
    list = []
    for i, a in enumerate( destinations ):
        print '%3s  %s' % ( i+1, a.strip('#') )
        if a[0] is not '#':
            list += [ i+1 ]
    print mode, mode is '-p'
    if   mode == '-p': list = [ len( destinations ) ]
    elif mode == '-g': list = []
    input = raw_input( '\nDestinations %r: ' % list ).split(',')
    if input[0]:
        list = [ int(i) for i in input ]
    for i in list:
        a = destinations[i-1].strip('#').split(' ')
        rsh = ' '.join( a[:-1] )
        rdir = a[-1]
        if   mode == '-d': deploy( rsh, rdir, args )
        elif mode == '-p': publish( rsh, rdir )
        elif mode == '-g': get( rsh, rdir, args )

