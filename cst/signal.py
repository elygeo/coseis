#!/usr/bin/env python
"""
Signal processing utilities
"""
import sys
import numpy as np

def time_function( pulse, t, fcorner=1.0 ):
    """
    Pulse time function with specified bandwidth.

    Parameters
    ----------
        pulse : function name (see source code below for available types).
        t : array of time samples.
        fcorner : corner frequency.

    Returns
    -------
        f : array of function samples.

    Amplitude spectra of the Brune and Gaussian functions fall to one half (-3 db)
    at the corner frequency. To specify a specific Gaussian spread (sigma) use:

        fcorner = sqrt(log(2) / 2) / (pi * sigma).

    To specify Brune pulse characteristic time (T) use:

        fcorner = 1 / (2 * pi * T).
    """
    t = np.asarray( t )
    f = np.zeros_like( t )
    if pulse == 'const':
        f.fill( 1.0 )
    elif pulse == 'delta':
        i = abs( t ).argmin()
        f[i] = 1.0 / (t[i+1] - t[i])
    elif pulse in ('step', 'integral_delta'):
        i = 0.0 < t
        f[i] = 1.0
        i = abs( t ).argmin()
        if t[i] == 0.0:
            f[i] = 0.5
    elif pulse == 'brune':
        a = 2.0 * np.pi * fcorner
        i = 0.0 < t
        f[i] = np.exp( -a * t[i] ) * a * a * t[i]
    elif pulse == 'integral_brune':
        a = 2.0 * np.pi * fcorner
        i = 0.0 < t
        f[i] = 1.0 - np.exp( -a * t[i] ) * (a * t[i] + 1.0)
    elif pulse == 'hann':
        a = 2.0 * np.pi * fcorner
        b = 0.5 / fcorner
        i = (-b < t) & (t < b)
        f[i] = fcorner + fcorner * np.cos( a * t[i] )
    elif pulse == 'integral_hann':
        a = 2.0 * np.pi * fcorner
        b = 0.5 / fcorner
        i = 0.0 < t
        f[i] = 1.0
        i = (-b < t) & (t < b)
        f[i] = 0.5 + fcorner * t[i] + np.sin( a * t[i] ) * 0.5 / np.pi
    elif pulse in ('gaussian', 'integral_ricker1'):
        #a = 2.0 * np.pi * np.pi * fcorner * fcorner
        a = np.pi * np.pi / np.log( 2.0 ) * fcorner * fcorner
        b = np.sqrt( a / np.pi )
        f = np.exp( -a * t * t ) * b
    elif pulse in ('ricker1', 'integral_ricker2' ):
        a = np.pi * np.pi / np.log( 2.0 ) * fcorner * fcorner
        b = np.sqrt( a / np.pi ) * 2.0 * a
        f = np.exp( -a * t * t ) * b * -t
    elif pulse == 'ricker2':
        a = np.pi * np.pi / np.log( 2.0 ) * fcorner * fcorner
        b = np.sqrt( a / np.pi ) * 4.0 * a
        f = np.exp( -a * t * t ) * b * (a * t * t - 0.5)
    else:
        sys.exit( 'invalid time func: ' + name )
    return f


def brune2gaussian( y, dt, fcorner, sigma=None, convolve='same' ):
    """
    Replace Brune pulse with Gaussian in a time series.

    WARNING: In progress and untested

    Parameters
    ----------
        y : time series.
        dt : time step length.
        fcorner : corner frequency of the Brune pulse, 1 / (2 * pi * T).
        sigma : Gaussian spread, defaults gives one-half amplitude at fcorner,
            sqrt(log(2) / 2) / (pi * fcorner).
    """
    y = np.array( y )
    n = y.shape[-1]
    w = 2.0 * np.pi * fcorner
    T = 1.0 / w
    if sigma == None:
        sigma = np.sqrt( 2.0 * np.log( 2 ) ) / w
    s = 1.0 / (sigma * sigma)
    t = np.arange( y.size ) * dt - 4.0 * sigma
    G = 1.0 - 2.0 * s * T * t - s * T * T * (1.0 - s * t * t)
    b = G * np.sqrt( 0.5 / np.pi * s ) * np.exp( -0.5 * s * t * t )
    y = dt * np.convolve( y, b, convolve )
    return y

def filter( x, dt, fcorner, btype='lowpass', order=2, repeat=0 ):
    """
    Butterworth or Hann window filter.

    Parameters
    ----------
        x : array of samples.
        dt : sampling interval.
        fcorner : corner frequency(ies).
        btype : 'lowpass', 'highpass', 'bandpass', 'bandstop', 'hann'.
        order : number of poles.
        repeat : 0 = single pass, 1 = two pass, -1 = two pass, zero-phase.

    Returns
    -------
        x : array of filtered samples.
    """
    if not fcorner:
        return x
    if btype == 'hann':
        n = int( 0.5 / (fcorner * dt) )
        if n > 0:
            w = 2.0 * np.pi * dt * fcorner
            f = (1.0 + np.cos( np.arange( -n, n+1 ) * w )) * dt * fcorner
            x = np.convolve( x, f, 'same' )
            if repeat:
                x = np.convolve( x, f, 'same' )
    else:
        import scipy.signal
        if type( fcorner ) in [list, tuple]:
            wn = 2.0 * dt * fcorner[0], 2.0 * dt * fcorner[1]
        else:
            wn = 2.0 * dt * fcorner
        b, a = scipy.signal.butter( order, wn, btype )
        x = scipy.signal.lfilter( b, a, x )
        if repeat < 0:
            x = scipy.signal.lfilter( b, a, x[...,::-1] )[...,::-1]
        elif repeat:
            x = scipy.signal.lfilter( b, a, x )
    return x

def spectrum( h, dt=1.0, shift=False, tzoom=10.0, db=None, legend=None, title='Forier spectrum', axes=None ):
    """
    Plot a time signal and it's Fourier spectrum.
    """
    import matplotlib.pyplot as plt

    h = np.array( h )
    n = h.shape[-1]
    H = np.fft.rfft( h ) * 2 / n
    if shift:
        h = np.fft.fftshift( h, axes=[-1] )
    t = np.arange( n ) * dt
    f = np.arange( n // 2 + 1 ) / (dt * n)
    if shift:
        t -= (n // 2) * dt
    tlim = t[0] / tzoom, t[-1] / tzoom
    if len( h.shape ) > 1:
        n = h.shape[0]
        t = t[None].repeat( n, 0 )
        f = f[None].repeat( n, 0 )
    if axes is None:
        plt.clf()
        fig = plt.gcf()
        fig.canvas.set_window_title( title )
        fig.subplots_adjust( left=0.125, right=0.975,
            bottom=0.1, top=0.975, wspace=0.3, hspace=0.3 )
        axes = [fig.add_subplot( i ) for i in 221, 222, 223, 224]

    ax = axes[0]
    ax.plot( t.T, h.T, '-' )
    ax.plot( tlim, [0, 0], 'k--' )
    ax.set_xlim( tlim )
    ax.set_xlabel( 'Time' )
    ax.set_ylabel( 'Amplitude' )

    ax = axes[1]
    y = abs( H )
    ax.semilogx( f.T, y.T, '-' )
    ax.axis( 'tight' )
    ax.set_xlabel( 'Frequency' )
    ax.set_ylabel( 'Amplitude' )

    ax = axes[2]
    y = np.arctan2( H.imag, H.real )
    ax.semilogx( f.T, y.T, '.' )
    ax.axis( 'tight' )
    pi = np.pi
    ax.set_ylim( -pi*1.1, pi*1.1 )
    ax.set_yticks( [-pi, 0, pi] )
    ax.set_yticklabels([ '$-\pi$', 0, '$\pi$' ])
    ax.set_xlabel( 'Frequency' )
    ax.set_ylabel( 'Phase' )

    ax = axes[3]
    y = 20 * np.log10( abs( H ) )
    y -= y.max()
    ax.semilogx( f.T, y.T, '-' )
    ax.axis( 'tight' )
    if db:
        ax.set_ylim( db[0], db[1] )
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
    shift = np.fft.fftshift

    # parameters
    n = 3200
    dt = 0.002
    flp = 3.0
    fbp = 2.0, 8.0
    s = n // 2 * dt

    # causal filters and pulses
    t = np.arange( n ) * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        ('Butter 4x2', filter( x, dt, flp, 'lowpass', 4, 1 )),
        ('Butter 2x2', filter( x, dt, flp, 'lowpass', 2, 1 )),
        ('Butter 4',   filter( x, dt, flp, 'lowpass', 4, 0 )),
        ('Butter 2',   filter( x, dt, flp, 'lowpass', 2, 0 )),
        ('Brune',      time_function( 'brune', t, flp )),
        #('B2G',        brune2gaussian( t, dt, flp )),
        #('Brune',  pulse( 'integral_brune', t + 0.5 * dt, flp )),
    )
    y = np.array( y ) * s
    #y[-1,1:] = np.diff( y[-1] ) / dt
    plt.figure( 2 )
    spectrum( y, dt, legend=leg, title='Causal' )

    # zero phase filters and pulses
    t = np.arange( n ) * dt - n // 2 * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        ('Butter 4x-2', filter( x, dt, flp, 'lowpass', 4, -1 )),
        ('Butter 2x-2', filter( x, dt, flp, 'lowpass', 2, -1 )),
        #('Hann filter', filter( x, dt, flp, 'hann', 0, 0 )),
        ('Hann',        time_function( 'hann', t, flp )),
        ('Gaussian',    time_function( 'gaussian', t, flp )),
        ('Ricker1',     time_function( 'ricker1', t - 0.5 * dt, flp ).cumsum() * dt),
        ('Ricker2',     time_function( 'ricker2', t - dt, flp ).cumsum().cumsum() * dt * dt),
        #('Int Hann',    time_function( 'integral_hann', t + 0.5 * dt, flp )),
    )
    y = np.array( y ) * s
    #y[-1,1:] = np.diff( y[-1] ) / dt
    y = np.fft.ifftshift( y, axes=[-1] )
    plt.figure( 1 )
    spectrum( y, dt, shift=True, tzoom=1, legend=leg, title='Zero phase' )

    # bandpass filters
    t = np.arange( n ) * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        ('Butter 4x2',  filter( x, dt, fbp, 'bandpass', 4, 1 )),
        ('Butter 2x2',  filter( x, dt, fbp, 'bandpass', 2, 1 )),
        ('Butter 4',    filter( x, dt, fbp, 'bandpass', 4, 0 )),
        ('Butter 2',    filter( x, dt, fbp, 'bandpass', 2, 0 )),
    )
    y = np.array( y ) * s
    plt.figure( 3 )
    spectrum( y, dt, legend=leg, title='Bandpass' )

    return

# continue if command line
if __name__ == '__main__':
    test()

