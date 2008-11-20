#!/usr/bin/env python
"""
Remote install and execution
"""

def remote( rsh, dest, command=[] ):
    import os, sys
    cwd = os.getcwd()
    os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )
    rsync = 'rsync -avR --delete --include=email --include=w --include=sord.tgz --exclude-from=.ignore -e %r . %r' % ( rsh, dest )
    print dest
    print rsync
    os.system( rsync )
    if command:
        host = dest.split(':')[0]
        dir = dest.split(':')[1]
        cmd = 'cd %s; %s' % ( dir, command[0] )
        cmd = '%s %s "bash --login -c %r"' % ( rsh, host, cmd )
        print cmd
        os.system( cmd )
    os.chdir( cwd )
    return

if __name__ == '__main__':
    import sys
    remote( sys.argv[1], sys.argv[2], sys.argv[3:4] )

