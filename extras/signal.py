#!/usr/bin/env ipython -pylab -wthread
"""
Signal processing utilities
"""
import numpy

def lowpass( x, dt, cutoff, window='hann', repeat=0 ):
    """
    Lowpass filter

    x      : samples
    dt     : sampling interval
    cutoff : cutoff frequency
    window : can be either 'hann' for zero-phase Hann window filter
             or an integer n for an n-pole Butterworth filter.
    """
    if not cutoff:
        return x
    if window == 'hann':
        n = 2 * int( 0.5 / (cutoff * dt) ) + 1
        if n > 0:
            w = 0.5 - 0.5 * numpy.cos(
                2.0 * numpy.pi * numpy.arange( n ) / (n - 1) )
            w /= w.sum()
            x = numpy.convolve( x, w, 'same' )
            if repeat:
                x = numpy.convolve( x, w, 'same' )
    else:
        import scipy.signal
        wn = cutoff * 2.0 * dt
        b, a = scipy.signal.butter( window, wn )
        x = scipy.signal.lfilter( b, a, x )
        if repeat < 0:
            x = scipy.signal.lfilter( b, a, x[...,::-1] )[...,::-1]
        elif repeat:
            x = scipy.signal.lfilter( b, a, x )
    return x

def spectrum( h, dt=1.0, nf=None, legend=None, title='Forier spectrum', axes=None ):
    """
    Plot a time signal and it's Fourier spectrum.
    """
    import pylab

    h = numpy.array( h )
    nt = h.shape[-1]
    if not nf:
        nf = nt
    t = numpy.arange( nt ) * dt
    f = numpy.arange( nf / 2 + 1 ) / (dt * nf)
    tlim = t[0], t[-1]
    if len( h.shape ) > 1:
        n = h.shape[0]
        t = t[None].repeat( n, 0 )
        f = f[None].repeat( n, 0 )
    H = numpy.fft.rfft( h, nf )
    if axes == None:
        pylab.clf()
        pylab.gcf().canvas.set_window_title( title )
        pylab.subplots_adjust( left=0.125, right=0.975,
            bottom=0.1, top=0.975, wspace=0.3, hspace=0.3 )
        axes = (
            pylab.subplot( 221 ),
            pylab.subplot( 222 ),
            pylab.subplot( 223 ),
            pylab.subplot( 224 ),
        )

    pylab.axes( axes[0] )
    pylab.plot( t.T, h.T, '-' )
    pylab.plot( tlim, [0, 0], 'k--' )
    pylab.xlabel( 'Time' )
    pylab.ylabel( 'Amplitude' )

    pylab.axes( axes[1] )
    y = abs( H )
    y /= y.max()
    pylab.semilogx( f.T, y.T, '-' )
    pylab.axis( 'tight' )
    pylab.ylim( -0.05, 1.05 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude' )

    pylab.axes( axes[2] )
    y = numpy.arctan2( H.imag, H.real )
    pylab.semilogx( f.T, y.T, '.' )
    pylab.axis( 'tight' )
    pi = numpy.pi
    pylab.ylim( -pi*1.1, pi*1.1 )
    pylab.yticks( [ -pi, 0, pi ] )
    pylab.gca().set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Phase' )

    pylab.axes( axes[3] )
    y = 20 * numpy.log10( abs( H ) )
    y -= y.max()
    pylab.semilogx( f.T, -y.T, '-' )
    pylab.axis( 'tight' )
    pylab.ylim( 145, -5 )
    pylab.xlabel( 'Frequency' )
    pylab.ylabel( 'Amplitude (dB)' )
    if legend:
        pylab.legend( legend, loc='lower left' )

    pylab.draw()
    pylab.show()

    return axes

def test():
    """
    Test spectrum plot.
    """
    import pylab

    dt = 0.01
    cutoff = 0.5
    cutoff = 8.0
    cutoff = 2.0
    n = 1000
    x = numpy.zeros( n+1 )
    x[0] = 1
    shift  = numpy.fft.fftshift
    ishift = numpy.fft.ifftshift

    y = [
        lowpass( x, dt, cutoff, 2 ),    'Butter-2',
        lowpass( x, dt, cutoff, 2, 1 ), 'Butter-2x2',
        lowpass( x, dt, cutoff, 4, 1 ), 'Butter-4x2',
        lowpass( x, dt, cutoff, 4 ),    'Butter-4',
        lowpass( x, dt, cutoff, 8 ),    'Butter-8',
    ]
    pylab.figure( 1 )
    spectrum( y[::2], dt, legend=y[1::2] )

    y = [
        ishift( lowpass( shift( x ), dt, cutoff, 2, -1 ) ), 'Butter-2x-2',
        ishift( lowpass( shift( x ), dt, cutoff, 4, -1 ) ), 'Butter-4x-2',
        ishift( lowpass( shift( x ), dt, cutoff ) ),        'Hann',
    ]
    pylab.figure( 2 )
    spectrum( y[::2], dt, legend=y[1::2] )

    return

if __name__ == '__main__':
    test()

