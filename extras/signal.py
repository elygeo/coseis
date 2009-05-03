#!/usr/bin/env ipython -pylab -wthread
"""
Signal processing utilities
"""

def lowpass( x, dt, cutoff, window='hann', repeat=1 ):
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
        n = 2 * int( 0.5 / ( cutoff * dt ) ) + 1
        if n > 0:
            w = 0.5 - 0.5 * numpy.cos( 2.0 * numpy.pi * numpy.arange( n ) / ( n - 1 ) )
            w /= w.sum()
            for i in xrange( repeat ):
                x = numpy.convolve( x, w, 'same' )
    else:
        import scipy.signal
        wn = cutoff * 2.0 * dt
        b, a = scipy.signal.butter( window, wn )
        for i in xrange( repeat ):
            x = scipy.signal.lfilter( b, a, x )
    return x

def spectrum( h, dt=1.0, nf=None, legend=None ):
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
    tlim = t[0], t[-1]
    if len( h.shape ) > 1:
        n = h.shape[0]
        t = t[None].repeat( n, 0 )
        f = f[None].repeat( n, 0 )
    H = numpy.fft.rfft( h, nf )
    pylab.clf()

    ax = [ pylab.subplot( 221 ) ]
    pylab.plot( t.T, h.T, '-' )
    pylab.plot( tlim, [0,0], 'k--' )
    pylab.xlabel( 'Time' )
    pylab.ylabel( 'Amplitude' )
    pylab.title( 'n = %s' % nt )
    if legend:
        pylab.legend( legend )

    ax += [ pylab.subplot( 222 ) ]
    pi = numpy.pi
    y = numpy.arctan2( H.imag, H.real )
    pylab.semilogx( f.T, y.T, '.' )
    pylab.axis( 'tight' )
    pylab.ylim( -pi*1.1, pi*1.1 )
    pylab.yticks( [ -pi, 0, pi ] )
    pylab.gca().set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Phase' )
    pylab.title( 'n = %s' % nf )

    ax += [ pylab.subplot( 223 ) ]
    y = 20 * numpy.log10( abs( H ) )
    y -= y.max()
    pylab.semilogx( f.T, y.T, '.-' )
    pylab.axis( 'tight' )
    pylab.ylim( -145, 5 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude (dB)' )

    ax += [ pylab.subplot( 224 ) ]
    y = abs( H )
    y /= y.max()
    pylab.semilogx( f.T, y.T, '.-' )
    pylab.axis( 'tight' )
    pylab.ylim( -0.05, 1.05 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude' )

    pylab.draw()
    pylab.show()

    return ax

if __name__ == '__main__':
    import numpy, pylab

    dt = 0.01
    cutoff = 0.5
    cutoff = 8.0
    cutoff = 2.0
    n = 1000
    x = numpy.zeros( n+1 )
    x[0] = 1

    y = [
        lowpass( numpy.fft.fftshift( x ), dt, cutoff ),
        lowpass( x, dt, cutoff, 2, 2 ),
        lowpass( x, dt, cutoff, 4 ),
        lowpass( x, dt, cutoff, 4, 2 ),
    ]
    leg = 'Hann', 'Butter-2x2', 'Butter-4', 'Butter-4x2'

    y[0] = numpy.fft.ifftshift( y[0] )
    spectrum( y, dt, x.size, leg )

