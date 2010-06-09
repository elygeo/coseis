#!/usr/bin/env python
import sys
from tools import util

def command_line():
    args = sys.argv[1:]
    if args == ['path']:
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

