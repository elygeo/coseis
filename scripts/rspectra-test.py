#!/usr/bin/env python
"""
Test
"""
import numpy, sord

nt = 10
dt = 0.1
a = dt * numpy.arange( nt )
w = 1.0
d = 0.05
print( sord.rspectra.rspectra( a, dt, w, d ) )

