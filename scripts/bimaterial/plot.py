#!/usr/bin/env python
"""
Bimaterial problem
"""
import sord, pylab, sim

n = sim.nn[0], sim.nt
sl = numpy.fromfile( sim.rundir + '/out/slip', 'f' ).reshape( n[::-1] ).T
pylab.plot( sl[:,::20] )
pylab.show()

