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
        b = np.pi / a
        i = (-b < t) & (t < b)
        f[i] = 0.5 / np.pi * a * (1.0 + np.cos( a * t[i] ))
    elif pulse == 'integral_hann':
        a = 2.0 * np.pi * fcorner
        b = np.pi / a
        i = 0.0 < t
        f[i] = 1.0
        i = (-b < t) & (t < b)
        f[i] = 0.5 + 0.5 / np.pi * (a * t[i] + np.sin( a * t[i] ))
    elif pulse in ('gaussian', 'integral_ricker1'):
        a = 2.0 * np.pi * np.pi * fcorner * fcorner
        b = np.sqrt( a / np.pi )
        f = np.exp( -a * t * t ) * b
    elif pulse in ('ricker1', 'integral_ricker2' ):
        a = 2.0 * np.pi * np.pi * fcorner * fcorner
        b = np.sqrt( a / np.pi ) * 2.0 * a
        f = np.exp( -a * t * t ) * b * -t
    elif pulse == 'ricker2':
        a = 2.0 * np.pi * np.pi * fcorner * fcorner
        b = np.sqrt( a / np.pi ) * 4.0 * a
        f = np.exp( -a * t * t ) * b * (a * t * t - 0.5)
    else:
        sys.exit( 'invalid time func: ' + pulse )
    return f


def brune2gauss( x, dt, T, sigma=None, mode='same' ):
    """
    Deconvolve Brune pulse from time series and replace with Gaussian.

    Parameters
    ----------
        x : array of time series samples.
        dt : time step length.
        T : Brune pulse characteristic time.
        sigma : Gaussian spread.
        mode : 'same' or 'full' (see numpy.convolve).
    """
    x = np.array( x )
    if sigma == None:
        sigma = np.sqrt( 2.0 ) * T
    s = 1.0 / (sigma * sigma)
    n = int( 6.0 * sigma / dt )
    t = np.arange( -n, n+1 ) * dt
    G = 1.0 - 2.0 * s * T * t - s * T * T * (1.0 - s * t * t)
    b = dt * G * np.sqrt( 0.5 / np.pi * s ) * np.exp( -0.5 * s * t * t )
    x = np.apply_along_axis( np.convolve, -1, x, b, mode )
    return x

def filter( x, dt, fcorner, btype='lowpass', order=2, repeat=0, mode='same' ):
    """
    Apply Butterworth or Hann window filter along the last axis.

    Parameters
    ----------
        x : array of samples.
        dt : sampling interval.
        fcorner : corner frequency(ies).
        btype : 'lowpass', 'highpass', 'bandpass', 'bandstop', 'hann'.
        order : number of poles.
        repeat : 0 = single pass, 1 = two pass, -1 = two pass, zero-phase.
        mode : 'full' or 'same', see np.convolve

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
            b = (1.0 + np.cos( np.arange( -n, n+1 ) * w )) * dt * fcorner
            x = np.apply_along_axis( np.convolve, -1, x, b, mode )
            if repeat:
                x = np.apply_along_axis( np.convolve, -1, x, b, mode )
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

    # parameters
    n = 3200
    dt = 0.002
    flp = 3.0
    fbp = 2.0, 8.0
    s = n // 2 * dt

    # Brune deconvolution to Gaussian filter
    T = 0.5 / (np.pi * flp)
    t = np.arange( n ) * dt - n // 2 * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        (r'$T$',              brune2gauss( x, dt, T, T )),
        (r'$\sqrt{2\ln 2}T$', brune2gauss( x, dt, T, T * np.sqrt(2.0*np.log(2.0)))),
        (r'$\sqrt{2}T$',      brune2gauss( x, dt, T, T * np.sqrt(2.0) )),
        (r'$2T$',             brune2gauss( x, dt, T, T * 2.0 )),
    )
    y = np.array( y ) * s
    y = np.fft.ifftshift( y, axes=[-1] )
    plt.figure( 0 )
    spectrum( y, dt, shift=True, legend=leg, title='Deconvolution filters' )

    # causal filters and pulses
    t = np.arange( n ) * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        ('Butter 4x2', filter( x, dt, flp, 'lowpass', 4, 1 )),
        ('Butter 2x2', filter( x, dt, flp, 'lowpass', 2, 1 )),
        ('Butter 4',   filter( x, dt, flp, 'lowpass', 4, 0 )),
        ('Butter 2',   filter( x, dt, flp, 'lowpass', 2, 0 )),
        ('Brune',      time_function( 'brune', t, flp )),
        #('Brune',      time_function( 'integral_brune', t + 0.5 * dt, flp )),
    )
    y = np.array( y ) * s
    #y[-1,1:] = np.diff( y[-1] ) / dt
    plt.figure( 2 )
    spectrum( y, dt, legend=leg, title='Causal' )

    # zero phase filters and pulses
    t = np.arange( n ) * dt - n // 2 * dt
    x = time_function( 'delta', t )
    leg, y = zip(
        ('Butter 4x-2',         filter( x, dt, flp, 'lowpass', 4, -1 )),
        ('Butter 2x-2',         filter( x, dt, flp, 'lowpass', 2, -1 )),
        #('Hann filter',         filter( x, dt, flp, 'hann', 0, 0 )),
        ('Hann',                time_function( 'hann', t, flp )),
        ('Ga',                  time_function( 'gaussian', t, flp )),
        (r'Ga $\sqrt{2\ln 2}$', time_function( 'gaussian', t, flp*np.sqrt(0.5/np.log(2.0)) )),
        (r'Ga $\sqrt{2}$',      time_function( 'gaussian', t, flp*np.sqrt(0.5) )),
        #('Ricker1',     time_function( 'ricker1', t - 0.5 * dt, flp ).cumsum() * dt),
        #('Ricker2',     time_function( 'ricker2', t - dt, flp ).cumsum().cumsum() * dt * dt),
        #('Int Hann',    time_function( 'integral_hann', t + 0.5 * dt, flp )),
    )
    y = np.array( y ) * s
    #y[-1,1:] = np.diff( y[-1] ) / dt
    y = np.fft.ifftshift( y, axes=[-1] )
    plt.figure( 1 )
    spectrum( y, dt, shift=True, legend=leg, title='Zero phase' )

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

