#!/usr/bin/env ipython -pylab -wthread
"""
Inspect SRF source
"""
import numpy, pylab, sord, sim

meta, data = sord.source.srfb_read( sim._srf )
mu = 2670.0 * 3464.0 ** 2.0
m0 = mu * meta.potency
mw = ( numpy.log10( m0 ) - 9.05 ) / 1.5
print 'm0 = ', m0
print 'mw = ', mw
for k, v in [
    ( 'nt1   ', data.nt1   ),
    ( 'nt2   ', data.nt2   ),
    ( 'nt3   ', data.nt3   ),
    ( 'dt    ', data.dt    ),
    ( 't0    ', data.t0    ),
    ( 'lon   ', data.lon   ),
    ( 'lat   ', data.lat   ),
    ( 'dep   ', data.dep   ),
    ( 'strike', data.stk   ),
    ( 'dip   ', data.dip   ),
    ( 'rake  ', data.rake  ),
    ( 'area  ', data.area  ),
    ( 'slip1 ', data.slip1 ),
    ( 'slip2 ', data.slip2 ),
    ( 'slip3 ', data.slip3 ),
    ( 'sv1   ', data.sv1   ),
    ( 'sv2   ', data.sv2   ),
    ( 'sv3   ', data.sv3   ),
]:
    if len( v ):
        print '%6s %12g %12g %12g %12d' % ( k, v.min(), v.max(), v.mean(), v.size )

normalize = 0
normalize = 1
lowpass = 0.25,
lowpass = 2.0,
lowpass = 0.5,
lowpass = 1.0,
lowpass = 0.1,
lowpass = 0.0,

ns = data.nt1.size
dt = data.dt.max()
nt = data.nt1.max()
nt = 251
nf = 512
v  = numpy.zeros((ns,nt))
k  = 0
for j in xrange( ns ):
    n = data.nt1[j]
    if n:
        v[j,:n] = data.sv1[k:k+n]
        k = k + n
if normalize:
    m = v.max(1)
    m[m>0.0] = 1.0 / m[m>0.0]
    v = ( m * v.T ).T
if lowpass[0] > 0:
    v = sord.signal.lowpass( v, *lowpass )

V = abs( numpy.fft.rfft( v, nf, -1 ) )

t = numpy.arange( nt ) * dt
f = numpy.arange( nf / 2 + 1 ) / ( dt * nf )

pylab.figure(1)
pylab.clf()

pylab.subplot( 311 )
pylab.plot( t, v[0] )
pylab.xlabel( 'Time (s)' )
pylab.axis( 'tight' )

pylab.subplot( 312 )
pylab.semilogx( f, V[0] )
pylab.xlabel( 'Frequency (Hz)' )
pylab.axis( 'tight' )
pylab.ylim( 0, 20 )

pylab.subplot( 313 )
pylab.semilogx( f, 20 * numpy.log10( V[0] ) )
pylab.xlabel( 'Frequency (Hz)' )
pylab.axis( 'tight' )
pylab.ylim( -70, 30 )

pylab.draw()

pylab.figure(2)
pylab.clf()

pylab.subplot( 211 )
extent = 0, ns, t[0], t[-1]
pylab.imshow( v.T, extent=extent, aspect='auto', origin='lower' )
pylab.ylabel( 'Time (s)' )

pylab.subplot( 212 )
extent = 0, ns, f[0], f[-1]
pylab.imshow( abs( V.T ), extent=extent, aspect='auto', origin='lower' )
pylab.ylabel( 'Frequency (Hz)' )

pylab.draw()

pylab.show()

