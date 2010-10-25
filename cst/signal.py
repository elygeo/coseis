#!/usr/bin/env ipython -wthread
"""
Signal processing utilities
"""
import numpy as np

def lowpass( x, dt, cutoff, window='hann', repeat=0 ):
    """
    Lowpass filter

    Parameters
    ----------
        x : samples
        dt : sampling interval
        cutoff : cutoff frequency
        window : can be either 'hann' for zero-phase Hann window filter
                 or an integer n for an n-pole Butterworth filter.
    """
    if not cutoff:
        return x
    if window == 'hann':
        n = 2 * int( 0.5 / (cutoff * dt) ) + 1
        if n > 0:
            w = 0.5 - 0.5 * np.cos(
                2.0 * np.pi * np.arange( n ) / (n - 1) )
            w /= w.sum()
            x = np.convolve( x, w, 'same' )
            if repeat:
                x = np.convolve( x, w, 'same' )
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
    import matplotlib.pyplot as plt

    h = np.array( h )
    nt = h.shape[-1]
    if not nf:
        nf = nt
    t = np.arange( nt ) * dt
    f = np.arange( nf // 2 + 1 ) / (dt * nf)
    tlim = t[0], t[-1]
    if len( h.shape ) > 1:
        n = h.shape[0]
        t = t[None].repeat( n, 0 )
        f = f[None].repeat( n, 0 )
    H = np.fft.rfft( h, nf )
    if axes is None:
        plt.clf()
        fig = plt.gcf()
        fig.canvas.set_window_title( title )
        fig.subplots_adjust( left=0.125, right=0.975,
            bottom=0.1, top=0.975, wspace=0.3, hspace=0.3 )
        axes = (
            fig.add_subplot( 221 ),
            fig.add_subplot( 222 ),
            fig.add_subplot( 223 ),
            fig.add_subplot( 224 ),
        )

    ax = axes[0]
    ax.plot( t.T, h.T, '-' )
    ax.plot( tlim, [0, 0], 'k--' )
    ax.set_xlabel( 'Time' )
    ax.set_ylabel( 'Amplitude' )

    ax = axes[1]
    y = abs( H )
    y /= y.max()
    ax.semilogx( f.T, y.T, '-' )
    ax.axis( 'tight' )
    ax.set_ylim( -0.05, 1.05 )
    ax.set_xlabel( 'Frequency' )
    ax.set_ylabel( 'Amplitude' )

    ax = axes[2]
    y = np.arctan2( H.imag, H.real )
    ax.semilogx( f.T, y.T, '.' )
    ax.axis( 'tight' )
    pi = np.pi
    ax.set_ylim( -pi*1.1, pi*1.1 )
    ax.set_yticks( [ -pi, 0, pi ] )
    ax.set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    ax.set_xlabel( 'Frequency' )
    ax.set_ylabel( 'Phase' )

    ax = axes[3]
    y = 20 * np.log10( abs( H ) )
    y -= y.max()
    ax.semilogx( f.T, -y.T, '-' )
    ax.axis( 'tight' )
    ax.set_ylim( 145, -5 )
    ax.set_xlabel( 'Frequency' )
    ax.set_ylabel( 'Amplitude (dB)' )
    if legend:
        ax.legend( legend, loc='lower left' )

    plt.draw()
    plt.show()

    return axes

def test():
    """
    Test spectrum plot
    """
    import matplotlib.pyplot as plt

    dt = 0.01
    cutoff = 0.5
    cutoff = 8.0
    cutoff = 2.0
    n = 1000
    x = np.zeros( n+1 )
    x[0] = 1
    shift  = np.fft.fftshift
    ishift = np.fft.ifftshift

    y = [
        lowpass( x, dt, cutoff, 2 ),    'Butter-2',
        lowpass( x, dt, cutoff, 2, 1 ), 'Butter-2x2',
        lowpass( x, dt, cutoff, 4, 1 ), 'Butter-4x2',
        lowpass( x, dt, cutoff, 4 ),    'Butter-4',
    ]
    plt.figure( 1 )
    spectrum( y[::2], dt, legend=y[1::2] )

    y = [
        ishift( lowpass( shift( x ), dt, cutoff, 2, -1 ) ), 'Butter-2x-2',
        ishift( lowpass( shift( x ), dt, cutoff, 4, -1 ) ), 'Butter-4x-2',
        ishift( lowpass( shift( x ), dt, cutoff ) ),        'Hann',
    ]
    plt.figure( 2 )
    spectrum( y[::2], dt, legend=y[1::2] )

    return

# continue if command line
if __name__ == '__main__':
    test()

