#!/usr/bin/env python
"""
TPV3 convergence test
"""
import os, glob, sord, numpy, pylab, scipy.interpolate
ndread = sord.util.ndread
interp2d = scipy.interpolate.RectBivariateSpline
degree = 1

dirs = glob.glob( '[0-9]*' )[3:]
dirs = glob.glob( '[0-9]*' )

meta = sord.util.loadmeta( dirs[0] )
n = meta.shape['flt-trup']
x0  = ndread( dirs[0] + '/out/flt-x1', n, [0,1] )
y0  = ndread( dirs[0] + '/out/flt-x2', n, [1,0] )
tt0 = ndread( dirs[0] + '/out/flt-trup', n ); tt_ = numpy.average( tt0 )
sv0 = ndread( dirs[0] + '/out/flt-psv', n );  sv_ = numpy.average( sv0 )
sx0 = ndread( dirs[0] + '/out/flt-su1', n )
sy0 = ndread( dirs[0] + '/out/flt-su2', n )
su_ = numpy.average( numpy.sqrt( sx0*sx0 + sy0*sy0 ) )
dx = []
ttres = []
sures = []
svres = []

for d in dirs[1:]:
    meta = sord.util.loadmeta( d )
    dx += [ int( meta.dx +0.5 ) ]
    n = meta.shape['flt-trup']
    x = ndread( d + '/out/flt-x1', n, [0,1] )
    y = ndread( d + '/out/flt-x2', n, [1,0] )

    f = ndread( d + '/out/flt-trup', n )
    f = tt0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    ttres += [ numpy.sqrt( numpy.average( f * f ) ) / tt_ * 100  ]

    f = ndread( d + '/out/flt-psv', n )
    f = sv0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    svres += [ numpy.sqrt( numpy.average( f * f ) ) / sv_ * 100 ]

    f = ndread( d + '/out/flt-su1', n )
    f = sx0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    g = ndread( d + '/out/flt-su2', n )
    g = sy0 - interp2d( x, y, g, kx=degree, ky=degree ).__call__( x0, y0 )
    sures += [ numpy.sqrt( numpy.average( f * f + g * g ) ) / su_ * 100 ]

for i in range( len( ttres ) ):
    print dirs[i+1], ttres[i], sures[i], svres[i]

# Plotting
pylab.rcdefaults()
font = { 'size': 8 }
pylab.rc( 'font', **font )
pylab.rc( 'figure', figsize=[3.2,3.2] )
pylab.rc( 'axes', linewidth=0.5 )
pylab.rc( 'ytick.minor', size=1 )
pylab.rc( 'ytick.major', size=2 )
pylab.rc( 'xtick.minor', size=0 )
pylab.rc( 'xtick.major', size=2 )
pylab.rc( 'lines', linewidth=0.5, color='k', markersize=3 )
pylab.subplots_adjust( left=.15, right=.95, bottom=.15, top=.95 )
pylab.clf()
pylab.loglog( dx, ttres, 'ko-' )
pylab.loglog( dx, sures, 'ks-', markerfacecolor=(.5,.5,.5) )
pylab.loglog( dx, svres, 'k^-', markerfacecolor='w', markersize=3.5 )
pylab.text( 0.8*dx[0], 0.8*ttres[0], 'Rupture time', ha='left', va='top' )
pylab.text( dx[-1], 0.8*sures[-1], 'Slip', ha='center', va='top' )
pylab.text( 0.8*dx[6], svres[6],  'Peak slip rate', ha='right' )
dx = [ x for x in dx if x not in [ 30, 100, 300 ] ]
pylab.xlim( 10, 750 )
pylab.gca().set_xticks( dx )
pylab.gca().set_xticklabels( dx )
y = [ '%g' % y for y in pylab.gca().get_yticks() ]
pylab.gca().set_yticklabels( y )
pylab.gca().yaxis.set_label_coords( -.12, .5 )
pylab.xlabel( 'Grid interval (m)' )
pylab.ylabel( 'RMS difference (%)' )
pylab.draw()
pylab.savefig( 'convergence.pdf', format='pdf' )
os.system( 'open convergence.pdf' )

