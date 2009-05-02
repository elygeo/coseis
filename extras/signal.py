#!/usr/bin/env ipython -pylab -wthread
"""
Signal processing utilities
"""

def lowpass( x, dt, cutoff, window='hann' ):
    """
    Lowpass filter

    x      : samples
    dt     : sampling interval
    cutoff : cutoff frequency
    window : can be either 'hann' for zero-phase Hann window filter
             or an integer n for an n-pole Butterworth filter.
    """
    if window == 'hann':
        import numpy
        n = int( 1.0 / ( cutoff * dt ) )
        if n > 0:
            w = 0.5 - 0.5 * numpy.cos( 2.0 * numpy.pi * numpy.arange( n ) / ( n - 1 ) )
            w /= w.sum()
            x = numpy.convolve( x, w, 'same' )
    else:
        import scipy.signal
        wn = cutoff * 2.0 * dt
        b, a = scipy.signal.butter( window, wn )
        x = scipy.signal.lfilter( b, a, x )
    return x

def spectrum( h, dt=1.0, nf=None ):
    """
    Plot a time signal and it's Fourier spectrum.
    """
    import numpy, pylab
    h = numpy.array( h )
    nt = h.shape[-1]
    if not nf:
        nf = nt
    t = numpy.arange( nt ) * dt
    f = numpy.arange( nf / 2 + 1 ) / ( dt * nf )
    H = numpy.fft.rfft( h, nf )
    pylab.clf()

    ax = [ pylab.subplot( 221 ) ]
    pylab.plot( t, h )
    pylab.plot( [t[0],t[-1]], [0,0], 'k--' )
    pylab.xlabel( 'Time' )
    pylab.ylabel( 'Amplitude' )
    pylab.title( 'n = %s' % nt )

    ax += [ pylab.subplot( 222 ) ]
    pi = numpy.pi
    y = numpy.arctan2( H.imag, H.real )
    pylab.plot( f, y )
    pylab.ylim( -pi, pi )
    pylab.yticks( [ -pi, 0, pi ] )
    pylab.gca().set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Phase' )
    pylab.title( 'n = %s' % nf )

    ax += [ pylab.subplot( 223 ) ]
    y = 20 * numpy.log10( abs( H ) )
    pylab.semilogx( f, y )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude (dB)' )

    ax += [ pylab.subplot( 224 ) ]
    y = abs( H )
    pylab.semilogx( f, y )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude' )
    pylab.draw()
    pylab.show()

    return ax

if __name__ == '__main__':
    import numpy, pylab

    dt = 0.01
    cutoff = 1.0
    x = numpy.random.randn( 1000 )
    x -= x.mean()
    x /= x.sum()
    w = lowpass( 1, dt, cutoff )

    pylab.figure(1)
    spectrum( w, dt, 8*w.size )

    pylab.figure(2)
    spectrum( x, dt, 8*x.size )

    pylab.figure(3)
    y = lowpass( x, dt, cutoff )
    spectrum( y, dt, 8*x.size )

    pylab.figure(4)
    y = lowpass( x, dt, cutoff, 1 )
    spectrum( y, dt, 8*x.size )

    pylab.figure(5)
    y = lowpass( x, dt, cutoff, 2 )
    spectrum( y, dt, 8*x.size )

    pylab.figure(6)
    y = lowpass( x, dt, cutoff, 4 )
    spectrum( y, dt, 8*x.size )

