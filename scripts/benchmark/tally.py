#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, glob
import numpy as np

normalize = 0
nproc = []
tt = []

for path in glob.glob( '[0-9]*' ):
    path += os.sep
    meta = sord.load( path + 'meta.py' )
    nproc += [ np.product( meta.nproc3 ) ]
    t = np.fromfile( path + 'prof/8step', 'f' )
    tt += [ np.sum( t[1:-1] ) / (len(t)-2) ]

if normalize:
    tt = [ t / tt[0] for t in tt ]

print 'time cores'
for n, t in zip( nproc, tt ):
    print '%4.2f %d' % (t, n)

if 0:
    import matplotlib.pyplot as plt
    n = len( tt )
    ax = plt.plot( tt, 'ko-' )[0].axes
    ax.hold( True )
    ax.plot( [-1, n], [tt[0],tt[0]], 'k--' )
    ax.set_xticks( range(n) )
    ax.set_xticklabels( nproc )
    ax.set_title( 'SORD weak scaling benchmark - TACC Ranger' )
    ax.set_xlabel( 'Cores' )
    if normalize:
        ax.set_ylabel( 'Normalized run time' )
        ax.axis([-1, n, 0, 4])
    else:
        ax.set_ylabel( 'Time/step (s)' )
        ax.axis( [ -1, n, 0, 2*int(numpy.average(tt)+0.5) ] )
    ax.figure.savefig( 'bench.pdf', format='pdf' )
    plt.draw()
    plt.show()

