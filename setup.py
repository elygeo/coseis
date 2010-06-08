#!/usr/bin/env python
import os, sys
from util import util

def rspec():
    cwd = os.getcwd()
    path = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( os.path.join( path, 'util' ) )
    if not os.path.isfile( 'rspectra.so' ):
        os.system( 'f2py -c -m rspectra rspectra.f90' )
    os.chdir( cwd )

def command_line():
    args = sys.argv[1:]
    if args == []:
        rspec()
    elif args == ['path']:
        util.install_path( __file__ )
    elif args[0] == ['unpath']:
        util.uninstall_path( __file__ )
    elif args[0] == ['install']:
        util.install( __file__ )
    elif args[0] == ['uninstall']:
        util.uninstall( __file__ )
    else:
        sys.exit( 'Unknown option: %s' % args )

if __name__ == '__main__':
    command_line()

