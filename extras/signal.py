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
        from numpy import cos, pi, arange, convolve
        n = 2 * int( 0.5 / ( cutoff * dt ) ) + 1
        if n > 0:
            w = 0.5 - 0.5 * cos( 2.0 * pi * arange( n ) / ( n - 1 ) )
            w /= w.sum()
            for i in xrange( repeat ):
                x = convolve( x, w, 'same' )
    else:
        import scipy.signal
        wn = cutoff * 2.0 * dt
        b, a = scipy.signal.butter( window, wn )
        for i in xrange( repeat ):
            x = scipy.signal.lfilter( b, a, x )
    return x

def spectrum( h, dt=1.0, nf=None, legend=None, title='Fourier spectrum' ):
    """
    Plot a time signal and it's Fourier spectrum.
    """
    import pylab
    from numpy import array, arange, fft, pi, arctan2, log10
    h = array( h )
    nt = h.shape[-1]
    if not nf:
        nf = nt
    t = arange( nt ) * dt
    f = arange( nf / 2 + 1 ) / ( dt * nf )
    tlim = t[0], t[-1]
    if len( h.shape ) > 1:
        n = h.shape[0]
        t = t[None].repeat( n, 0 )
        f = f[None].repeat( n, 0 )
    H = fft.rfft( h, nf )
    pylab.clf()
    pylab.gcf().canvas.set_window_title( title )

    ax = [ pylab.subplot( 221 ) ]
    pylab.plot( t.T, h.T, '-' )
    pylab.plot( tlim, [0,0], 'k--' )
    pylab.xlabel( 'Time' )
    pylab.ylabel( 'Amplitude' )
    pylab.title( 'n = %s' % nt )

    ax += [ pylab.subplot( 222 ) ]
    y = abs( H )
    y /= y.max()
    pylab.semilogx( f.T, y.T, '-' )
    pylab.axis( 'tight' )
    pylab.ylim( -0.05, 1.05 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude' )

    ax += [ pylab.subplot( 223 ) ]
    y = arctan2( H.imag, H.real )
    pylab.semilogx( f.T, y.T, '.' )
    pylab.axis( 'tight' )
    pylab.ylim( -pi*1.1, pi*1.1 )
    pylab.yticks( [ -pi, 0, pi ] )
    pylab.gca().set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Phase' )
    pylab.title( 'n = %s' % nf )

    ax += [ pylab.subplot( 224 ) ]
    y = 20 * log10( abs( H ) )
    y -= y.max()
    pylab.semilogx( f.T, y.T, '-' )
    pylab.axis( 'tight' )
    pylab.ylim( -145, 5 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude (dB)' )
    if legend:
        pylab.legend( legend, loc='lower left' )

    pylab.draw()
    pylab.show()

    return ax

if __name__ == '__main__':
    from numpy import zeros, fft

    dt = 0.01
    cutoff = 0.5
    cutoff = 8.0
    cutoff = 2.0
    n = 1000
    x = zeros( n+1 )
    x[0] = 1

    y = [
        lowpass( fft.fftshift( x ), dt, cutoff ),
        lowpass( x, dt, cutoff, 2, 2 ),
        lowpass( x, dt, cutoff, 4 ),
        lowpass( x, dt, cutoff, 4, 2 ),
    ]
    leg = 'Hann', 'Butter-2x2', 'Butter-4', 'Butter-4x2'

    y[0] = fft.ifftshift( y[0] )
    spectrum( y, dt, x.size, leg )

