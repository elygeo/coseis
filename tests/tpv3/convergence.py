#!/usr/bin/env python
"""
TPV3 convergence test
"""
import glob, sord, numpy, pylab, scipy.interpolate
ndread = sord.util.ndread
interp2d = scipy.interpolate.RectBivariateSpline

dirs = glob.glob( '[0-9]*' )

meta = sord.util.loadmeta( dirs[0] )
n   = meta.out['flt-trup'][1]
x0  = ndread( dirs[0] + '/out/flt-x1', n, [0,1] )
y0  = ndread( dirs[0] + '/out/flt-x2', n, [1,0] )
tt0 = ndread( dirs[0] + '/out/flt-trup', n )
sv0 = ndread( dirs[0] + '/out/flt-psv', n )
sx0 = ndread( dirs[0] + '/out/flt-su1', n )
sy0 = ndread( dirs[0] + '/out/flt-su2', n )
dx = []
ttres = []
sures = []
svres = []

for d in dirs[1:]:
    meta = sord.util.loadmeta( d )
    dx += [ int( meta.dx +0.5 ) ]
    n = meta.out['flt-trup'][1]
    x = ndread( d + '/out/flt-x1', n, [0,1] )
    y = ndread( d + '/out/flt-x2', n, [1,0] )

    f = ndread( d + '/out/flt-trup', n )
    f = tt0 - interp2d( x, y, f, kx=1, ky=1 ).__call__( x0, y0 )
    ttres += [ numpy.sqrt( numpy.average( f * f ) ) ]

    f = ndread( d + '/out/flt-psv', n )
    f = sv0 - interp2d( x, y, f, kx=1, ky=1 ).__call__( x0, y0 )
    svres += [ numpy.sqrt( numpy.average( f * f ) ) ]

    f = ndread( d + '/out/flt-su1', n )
    f = sx0 - interp2d( x, y, f, kx=1, ky=1 ).__call__( x0, y0 )
    g = ndread( d + '/out/flt-su2', n )
    g = sy0 - interp2d( x, y, g, kx=1, ky=1 ).__call__( x0, y0 )
    sures += [ numpy.sqrt( numpy.average( f * f + g * g ) ) ]

for i in range( len( ttres ) ):
    print dirs[i+1], ttres[i], sures[i], svres[i]

pylab.clf()
pylab.loglog( dx, ttres, 'ko-', dx, sures, 'ks-', dx, svres, 'k^-' )
del( dx[8], dx[2] )
pylab.gca().set_xticks( dx )
pylab.gca().set_xticklabels( dx )
pylab.xlabel( 'Grid interval \nabla x (m)' )
pylab.ylabel( 'RMS difference' )
pylab.legend( [ 'Rupture time', 'Slip', 'Peak slip rate' ], loc='upper left' )
pylab.draw()
pylab.savefig( 'convergence.pdf', format='pdf' )
#pylab.show()

