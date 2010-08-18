#!/usr/bin/env python
"""
Tally benchmarks
"""
import os, glob
import numpy as np
import matplotlib.pyplot as plt
import cst

normalize = 0
nproc = []
tt = []

for path in glob.glob( 'run/[0-9]*' ):
    path += os.sep
    meta = cst.util.load( path + 'meta.py' )
    nproc += [ np.product( meta.nproc3 ) ]
    t = np.fromfile( path + 'prof/8step', 'f' )
    tt += [ np.sum( t[1:-1] ) / (len(t)-2) ]

if normalize:
    tt = [ t / tt[0] for t in tt ]

print 'cores time ideal'
for n, t in zip( nproc, tt ):
    print '%5d %4.2f %4.2f' % (n, t, tt[0])

if 1:
    n = len( tt )
    fig = plt.figure()
    ax = fig.add_subplot( 111 )
    ax.plot( tt, 'ko-' )
    ax.plot( [0, n], [tt[0],tt[0]], 'k--' )[0].set_dashes( (4,2) )
    ax.set_xticks( range(n) )
    ax.set_xticklabels( nproc )
    ax.set_title( 'SORD weak scaling benchmark - TACC Ranger' )
    ax.set_xlabel( 'Cores' )
    if normalize:
        ax.set_ylabel( 'Normalized run time' )
        ax.axis([0, n-1, 0, 2])
    else:
        ax.set_ylabel( 'Time/step (s)' )
        h = 2 * int( np.average(tt) + 0.5 )
        ax.axis( [0, n-1, 0, h] )
    ax.legend( ('Time to solution', 'Ideal') )
    fig.savefig( 'bench.pdf', format='pdf' )

