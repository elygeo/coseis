#!/usr/bin/env python
#!/usr/bin/env ipython --gui=wx -i --
"""
SCEC Community Fault Model Explorer
"""

if __name__ != '__main__':
    raise Exception('Not a module')

import sys, getopt
import cst

opts, argv = getopt.getopt(sys.argv[1:], 's:')
opts = dict(opts)
if '-s' in opts:
    split = int(opts['-s'])
    prefix, faults = cst.cfm.search(argv, split)
else:
    prefix, faults = cst.cfm.search(argv)
cst.cfm.explore(prefix, faults)

