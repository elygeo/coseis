#!/usr/bin/env python
"""
Bimaterial problem
"""

import sord, pylab

sl = sord.util.ndread( 'run/01/out/slip', [401,200] )
pylab.plot( sl )
pylab.show()

