#!/usr/bin/env python
"""
Remote install and execution
"""

def deploy( rsh, dest, command=[] ):
    import os, sys
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --include=accounts --include=email --include=w --include=sord.tgz --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print dest
    print rsync
    #os.system( rsync )
    for cmd in command:
        host = dest.split(':')[0]
        dir = dest.split(':')[1]
        cmd = 'cd %s; %s' % ( dir, cmd )
        cmd = '%s %s "bash --login -c %r"' % ( rsh, host, cmd )
        print cmd
        #os.system( cmd )
    os.chdir( cwd )
    return

# TODO: get and put
if __name__ == '__main__':
    import sys
    print __doc__
    accounts = file( 'accounts', 'r' ).readlines()
    accounts = [ a.strip() for a in accounts ]
    accounts = [ a for a in accounts if a[0] is not '#' ]
    i = 0
    for a in accounts:
        i = i + 1
        print '%3s  %s' % ( i, a )
    list = range( 1, len(accounts)+1 )
    input = raw_input( '\nhosts %r: ' % list ).split(',')
    if input[0]:
        list = [ int(i) for i in input ]
    for i in list:
        a = accounts[i-1].strip()
        rsh = ' '.join( a.split(' ')[:-1] )
        dest = a.split(' ')[-1]
        deploy( rsh, dest, sys.argv[1:] )

