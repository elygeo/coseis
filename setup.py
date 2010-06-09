#!/usr/bin/env python
import sys
from coseis import tools, sord, cvm4

def command_line():
    target = sys.argv[-1]
    if target == 'all':
        tools.build()
        sord.build()
        cvm4.build()
        util.install_path( __file__ )
    elif target == 'tools':
        tools.build()
    elif target == 'sord':
        sord.build()
    elif target == 'cvm4':
        cvm4.build()
    elif target == 'path':
        util.install_path( __file__ )
    elif target == 'unpath':
        util.uninstall_path( __file__ )
    elif target == 'install':
        util.install( __file__ )
    elif target == 'uninstall':
        util.uninstall( __file__ )
    else:
        sys.exit( 'Unknown target' )

if __name__ == '__main__':
    command_line()

