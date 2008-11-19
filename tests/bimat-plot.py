#!/usr/bin/env python
"""
Bimaterial problem
"""

import sord, pylab

sl = sord.util.ndread( 'slip', [401,200] )
pylab.plot( sl )
pylab.show()



