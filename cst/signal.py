#!/usr/bin/env python
"""
Signal processing tools.
"""

# response spectra extension
def build():
    try:
        from . import rspectra
        rspectra
    except ImportError:
        import os, shlex
        from numpy.distutils.core import setup, Extension
        cwd = os.getcwd()
        os.chdir(os.path.dirname(__file__))
        ext = [Extension('rspectra', ['rspectra.f90'])]
        setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
        os.chdir(cwd)
try:
    from .rspectra import rspectra
    rspectra
except ImportError:
    pass


def time_function(pulse, t, tau=1.0):
    """
    Pulse time function with specified bandwidth.

    Parameters
    ----------
    pulse: function name (see source code below for available types).
    t: array of time samples.
    tau: characteristic time.

    Returns
    -------
    f: array of function samples.
    """
    import math
    import numpy as np
    t = np.asarray(t)
    f = np.zeros_like(t)
    if pulse == 'const':
        f.fill(1.0)
    elif pulse == 'delta':
        i = abs(t).argmin()
        f[i] = 1.0 / (t[i+1] - t[i])
    elif pulse in ('step', 'integral_delta'):
        i = 0.0 < t
        f[i] = 1.0
        i = abs(t).argmin()
        if t[i] == 0.0:
            f[i] = 0.5
    elif pulse == 'brune':
        a = 1.0 / tau
        i = 0.0 < t
        f[i] = np.exp(-a * t[i]) * a * a * t[i]
    elif pulse == 'integral_brune':
        a = 1.0 / tau
        i = 0.0 < t
        f[i] = 1.0 - np.exp(-a * t[i]) * (a * t[i] + 1.0)
    elif pulse == 'hann':
        a = 1.0 / tau
        b = math.pi * tau
        i = (-b < t) & (t < b)
        f[i] = 0.5 / math.pi * a * (1.0 + np.cos(a * t[i]))
    elif pulse == 'integral_hann':
        a = 1.0 / tau
        b = math.pi * tau
        i = 0.0 < t
        f[i] = 1.0
        i = (-b < t) & (t < b)
        f[i] = 0.5 + 0.5 / math.pi * (a * t[i] + np.sin(a * t[i]))
    elif pulse in ('gaussian', 'integral_ricker1'):
        a = 0.5 / (tau * tau)
        b = math.sqrt(a / math.pi)
        f = np.exp(-a * t * t) * b
    elif pulse in ('ricker1', 'integral_ricker2'):
        a = 0.5 / (tau * tau)
        b = math.sqrt(a / math.pi) * 2.0 * a
        f = np.exp(-a * t * t) * b * -t
    elif pulse == 'ricker2':
        a = 0.5 / (tau * tau)
        b = math.sqrt(a / math.pi) * 4.0 * a
        f = np.exp(-a * t * t) * b * (a * t * t - 0.5)
    else:
        raise Exception('invalid time func: ' + pulse)
    return f


def brune2gauss(x, dt, tau, sigma=None, mode='same'):
    """
    Deconvolve Brune pulse from time series and replace with Gaussian.

    Parameters
    ----------
    x: array of time series samples.
    dt: time step length.
    tau: Brune pulse characteristic time.
    sigma: Gaussian spread.
    mode: 'same' or 'full' (see numpy.convolve).
    """
    import math
    import numpy as np
    x = np.asarray(x)
    if sigma == None:
        sigma = math.sqrt(2.0) * tau
    s = 1.0 / (sigma * sigma)
    n = int(6.0 * sigma / dt)
    t = np.arange(-n, n+1) * dt
    G = 1.0 - 2.0 * s * tau * t - s * tau * tau * (1.0 - s * t * t)
    b = dt * G * math.sqrt(0.5 / math.pi * s) * np.exp(-0.5 * s * t * t)
    x = np.apply_along_axis(np.convolve, -1, x, b, mode)
    return x


def filter(x, dt, fcorner, btype='lowpass', order=2, repeat=0, mode='same'):
    """
    Apply Butterworth or Hann window filter to time series.

    Parameters
    ----------
    x: array of samples.
    dt: sampling interval.
    fcorner: corner frequency(ies).
    btype: 'lowpass', 'highpass', 'bandpass', 'bandstop', 'hann'.
    order: number of poles.
    repeat: 0 = single pass, 1 = two pass, -1 = two pass, zero-phase.
    mode: 'full' or 'same', see np.convolve

    Returns
    -------
    x: array of filtered samples.
    """
    import math
    import numpy as np
    if not fcorner:
        return x
    if btype == 'hann':
        n = int(0.5 / (fcorner * dt))
        if n > 0:
            w = 2.0 * math.pi * dt * fcorner
            b = (1.0 + np.cos(np.arange(-n, n+1) * w)) * dt * fcorner
            x = np.apply_along_axis(np.convolve, -1, x, b, mode)
            if repeat:
                x = np.apply_along_axis(np.convolve, -1, x, b, mode)
    else:
        import scipy.signal
        if type(fcorner) in [list, tuple]:
            wn = 2.0 * dt * fcorner[0], 2.0 * dt * fcorner[1]
        else:
            wn = 2.0 * dt * fcorner
        b, a = scipy.signal.butter(order, wn, btype)
        x = scipy.signal.lfilter(b, a, x)
        if repeat < 0:
            x = scipy.signal.lfilter(b, a, x[...,::-1])[...,::-1]
        elif repeat:
            x = scipy.signal.lfilter(b, a, x)
    return x


def spectrum(h, dt=1.0, shift=False, tzoom=10.0, db=None, legend=None, title='Forier spectrum', axes=None):
    """
    Plot a time signal and it's Fourier spectrum.
    """
    import math
    import numpy as np
    import matplotlib.pyplot as plt

    h = np.asarray(h)
    n = h.shape[-1]
    H = np.fft.rfft(h) * 2 / n
    if shift:
        h = np.fft.fftshift(h, axes=[-1])
    t = np.arange(n) * dt
    f = np.arange(n // 2 + 1) / (dt * n)
    if shift:
        t -= (n // 2) * dt
    tlim = t[0] / tzoom, t[-1] / tzoom
    if len(h.shape) > 1:
        n = h.shape[0]
        t = t[None].repeat(n, 0)
        f = f[None].repeat(n, 0)
    if axes is None:
        plt.clf()
        fig = plt.gcf()
        fig.canvas.set_window_title(title)
        fig.subplots_adjust(left=0.125, right=0.975,
            bottom=0.1, top=0.975, wspace=0.3, hspace=0.3)
        axes = [fig.add_subplot(i) for i in [221, 222, 223, 224]]

    ax = axes[0]
    ax.plot(t.T, h.T, '-')
    ax.plot(tlim, [0, 0], 'k--')
    ax.set_xlim(tlim)
    ax.set_xlabel('Time')
    ax.set_ylabel('Amplitude')

    ax = axes[1]
    y = abs(H)
    ax.semilogx(f.T, y.T, '-')
    ax.axis('tight')
    ax.set_xlabel('Frequency')
    ax.set_ylabel('Amplitude')

    ax = axes[2]
    y = np.arctan2(H.imag, H.real)
    ax.semilogx(f.T, y.T, '.')
    ax.axis('tight')
    pi = math.pi
    ax.set_ylim(-pi*1.1, pi*1.1)
    ax.set_yticks([-pi, 0, pi])
    ax.set_yticklabels(['$-\pi$', 0, '$\pi$'])
    ax.set_xlabel('Frequency')
    ax.set_ylabel('Phase')

    ax = axes[3]
    np.seterr(divide='ignore')
    y = 20 * np.log10(abs(H))
    y -= y.max()
    ax.semilogx(f.T, y.T, '-')
    ax.axis('tight')
    if db:
        ax.set_ylim(db[0], db[1])
    ax.set_xlabel('Frequency')
    ax.set_ylabel('Amplitude (dB)')
    if legend:
        ax.legend(legend, loc='lower left')

    plt.draw()

    return axes

def test():
    """
    Test spectrum plot
    """
    import math
    import numpy as np
    import matplotlib.pyplot as plt

    # parameters
    n = 3200
    dt = 0.002
    fbp = 2.0, 8.0
    flp = 3.0
    tau = 0.5 / (math.pi * flp)
    scale = n // 2 * dt

    # filter comparison
    t = np.arange(n) * dt - n // 2 * dt
    x = time_function('delta', t)
    leg, y = zip(
        ('Butter 1x2',              filter(x, dt, flp, 'lowpass', 1, 1)),
        ('Butter 2x2',              filter(x, dt, flp, 'lowpass', 2, 1)),
        ('Butter 2x-2',             filter(x, dt, flp, 'lowpass', 2, -1)),
        ('Hann filter',             filter(x, dt, flp, 'hann', 0, 0)),
        #('Hann',                   time_function('hann', t, tau)),
        ('Brune',                   time_function('brune', t, tau)),
        (r'Ga $\sqrt{2\ln 2}\tau$', time_function('gaussian', t, tau*np.sqrt(2*np.log(2)))),
        (r'Decon $\sqrt{2}\tau$',   brune2gauss(x, dt, tau, tau*np.sqrt(2))),
        #('Ricker1', time_function('ricker1', t - 0.5 * dt, tau).cumsum() * dt),
        #('Ricker2', time_function('ricker2', t - dt, tau).cumsum().cumsum() * dt * dt),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(0)
    spectrum(y, dt, shift=True, tzoom=5, legend=leg,
        title='fc = %.1f, T = 0.5 / (pi * fc)' % flp)

    # Butterworth lowpass
    t = np.arange(n) * dt - n // 2 * dt
    x = time_function('delta', t)
    leg, y = zip(
        ('2 pole ',    filter(x, dt, flp, 'lowpass', 2, 0)),
        ('4 pole ',    filter(x, dt, flp, 'lowpass', 4, 0)),
        ('1 pole x2',  filter(x, dt, flp, 'lowpass', 1, 1)),
        ('2 pole x2',  filter(x, dt, flp, 'lowpass', 2, 1)),
        ('2 pole x-2', filter(x, dt, flp, 'lowpass', 2, -1)),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(2)
    spectrum(y, dt, shift=True, tzoom=5, legend=leg,
        title='Butterworth lowpass, fc = %.1f' % flp)

    # Butterworth bandpass
    t = np.arange(n) * dt
    x = time_function('delta', t)
    leg, y = zip(
        ('2 pole ',    filter(x, dt, fbp, 'bandpass', 2, 0)),
        ('4 pole ',    filter(x, dt, fbp, 'bandpass', 4, 0)),
        ('1 pole x2 ', filter(x, dt, fbp, 'bandpass', 1, 1)),
        ('2 pole x2',  filter(x, dt, fbp, 'bandpass', 2, 1)),
    )
    y = np.asarray(y) * scale
    plt.figure(3)
    spectrum(y, dt, legend=leg,
        title='Butterworth bandpass, fc = %.1f, %.1f' % fbp)

    # Brune deconvolution to Gaussian filter
    t = np.arange(n) * dt - n // 2 * dt
    x = time_function('delta', t)
    leg, y = zip(
        (r'$\tau$',              brune2gauss(x, dt, tau, tau)),
        (r'$\sqrt{2\ln 2}\tau$', brune2gauss(x, dt, tau, tau*np.sqrt(2*np.log(2)))),
        (r'$\sqrt{2}\tau$',      brune2gauss(x, dt, tau, tau*np.sqrt(2))),
        (r'$2\tau$',             brune2gauss(x, dt, tau, tau*2)),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(4)
    spectrum(y, dt, shift=True, legend=leg,
        title='Deconvolution, fc = %.1f, T = 0.5 / (pi * fc)' % flp)

    plt.ion()
    plt.show()
    return

# continue if command line
if __name__ == '__main__':
    build()
    test()

