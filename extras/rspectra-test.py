#!/usr/bin/env python

import rspectra
from numpy import arange

nt = 10
dt = 0.1
a = dt * arange( nt )
w = 1.0
d = 0.05
print( rspectra.rspectra( a, dt, w, d ) )

