#!/usr/bin/env python
"""
Remote install and execution
"""

def deploy( rsh, dest, command=[] ):
    import os, sys
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --include=destinations --include=email --include=w --include=sord.tgz --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print dest
    print rsync
    os.system( rsync )
    for cmd in command:
        host = dest.split(':')[0]
        dir = dest.split(':')[1]
        cmd = 'cd %s; %s' % ( dir, cmd )
        cmd = '%s %s "bash --login -c %r"' % ( rsh, host, cmd )
        print cmd
        os.system( cmd )
    os.chdir( cwd )
    return

# TODO: get and put
if __name__ == '__main__':
    import sys
    print __doc__
    destinations = [ a.strip() for a in file( 'destinations', 'r' ).readlines() ]
    list = []
    for i, a in enumerate( destinations ):
        print '%3s  %s' % ( i+1, a.strip('#') )
        if a[0] is not '#':
            list += [ i+1 ]
    input = raw_input( '\nDestinations %r: ' % list ).split(',')
    if input[0]:
        list = [ int(i) for i in input ]
    for i in list:
        a = destinations[i-1].strip('#').split(' ')
        rsh = ' '.join( a[:-1] )
        dest = a[-1]
        deploy( rsh, dest, sys.argv[1:] )

