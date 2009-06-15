#!/usr/bin/env ipython -pylab -wthread
"""
Inspect SRF source
"""
import numpy, pylab, sord, sim

# metadata
meta = {}
path = os.path.join( sim.srf_, 'meta.py' )
exec open( path ) in meta
dtype = meta['dtype']
potency = meta['potency']

mu = 2670.0 * 3464.0 ** 2.0
m0 = mu * potency
mw = (numpy.log10( m0 ) - 9.05) / 1.5
print 'm0 = ', m0
print 'mw = ', mw

normalize = 0
normalize = 1
lowpass = 0.25,
lowpass = 2.0,
lowpass = 0.5,
lowpass = 1.0,
lowpass = 0.1,
lowpass = 0.0,

nt_ = numpy.fromfile( path + 'nt1', 'i' )
dt_ = numpy.fromfile( path + 'dt',  dtype )
sv  = numpy.fromfile( path + 'sv1', dtype )

ns = nt_.size
nt = nt_.max()
dt = dt_.max()
nt = 251
nf = 512
v  = numpy.zeros( (ns, nt) )
k  = 0
for j in xrange( ns ):
    n = nt_[j]
    if n:
        v[j,:n] = sv[k:k+n]
        k = k + n
if normalize:
    m = v.max(1)
    m[m>0.0] = 1.0 / m[m>0.0]
    v = ( m * v.T ).T
if lowpass[0] > 0:
    v = sord.signal.lowpass( v, *lowpass )

V = abs( numpy.fft.rfft( v, nf, -1 ) )

t = numpy.arange( nt ) * dt
f = numpy.arange( nf / 2 + 1 ) / (dt * nf)

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

