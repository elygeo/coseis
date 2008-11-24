#!/usr/bin/env python
"""
TPV3
"""
import math, numpy, pylab, sord

bi_dir = ''
so_dir = ''
prm = sord.util.objectify( sord.util.load( so_dir + 'parameters.py' ) )
for f in prm.fieldio:
    if f[7] is 'trup': break
ii = f[6]
n = [ ( i[1] - i[0] ) / i[2] + 1 for i in ii ]
x1 = sord.util.ndread( so_dir + 'out/x1', n[:2] )
x2 = sord.util.ndread( so_dir + 'out/x2', n[:2] )
trup = sord.util.ndread( so_dir + 'out/su1', n[:2] )
pylab.pcolor( x1, x2, trup )
pylab.axis( 'image' )

#sord.util.ndread( bi_dir + 'trup', (150, 300) )
pylab.draw()
pylab.show()

