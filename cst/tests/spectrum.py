#!/usr/bin/env ipython -i --gui=wx

def test():
    """
    Test spectrum plot
    """
    import math
    import numpy as np
    import matplotlib.pyplot as plt
    from cst import signal

    # parameters
    n = 3200
    dt = 0.002
    fbp = 2.0, 8.0
    flp = 3.0
    tau = 0.5 / (math.pi * flp)
    scale = n // 2 * dt

    # filter comparison
    t = np.arange(n) * dt - n // 2 * dt
    x = signal.time_function('delta', t)
    leg, y = zip(
        ('Butter 1x2',              signal.filter(x, dt, flp, 'lowpass', 1, 1)),
        ('Butter 2x2',              signal.filter(x, dt, flp, 'lowpass', 2, 1)),
        ('Butter 2x-2',             signal.filter(x, dt, flp, 'lowpass', 2, -1)),
        ('Hann filter',             signal.filter(x, dt, flp, 'hann', 0, 0)),
        #('Hann',                    signal.time_function('hann', t, tau)),
        ('Brune',                   signal.time_function('brune', t, tau)),
        (r'Ga $\sqrt{2\ln 2}\tau$', signal.time_function('gaussian', t, tau*np.sqrt(2*np.log(2)))),
        (r'Decon $\sqrt{2}\tau$',   signal.brune2gauss(x, dt, tau, tau*np.sqrt(2))),
        #('Ricker1', signal.time_function('ricker1', t - 0.5 * dt, tau).cumsum() * dt),
        #('Ricker2', signal.time_function('ricker2', t - dt, tau).cumsum().cumsum() * dt * dt),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(0)
    signal.spectrum(y, dt, shift=True, tzoom=5, legend=leg,
        title='fc = %.1f, T = 0.5 / (pi * fc)' % flp)

    # Butterworth lowpass
    t = np.arange(n) * dt - n // 2 * dt
    x = signal.time_function('delta', t)
    leg, y = zip(
        ('2 pole ',    signal.filter(x, dt, flp, 'lowpass', 2, 0)),
        ('4 pole ',    signal.filter(x, dt, flp, 'lowpass', 4, 0)),
        ('1 pole x2',  signal.filter(x, dt, flp, 'lowpass', 1, 1)),
        ('2 pole x2',  signal.filter(x, dt, flp, 'lowpass', 2, 1)),
        ('2 pole x-2', signal.filter(x, dt, flp, 'lowpass', 2, -1)),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(2)
    signal.spectrum(y, dt, shift=True, tzoom=5, legend=leg,
        title='Butterworth lowpass, fc = %.1f' % flp)

    # Butterworth bandpass
    t = np.arange(n) * dt
    x = signal.time_function('delta', t)
    leg, y = zip(
        ('2 pole ',    signal.filter(x, dt, fbp, 'bandpass', 2, 0)),
        ('4 pole ',    signal.filter(x, dt, fbp, 'bandpass', 4, 0)),
        ('1 pole x2 ', signal.filter(x, dt, fbp, 'bandpass', 1, 1)),
        ('2 pole x2',  signal.filter(x, dt, fbp, 'bandpass', 2, 1)),
    )
    y = np.asarray(y) * scale
    plt.figure(3)
    signal.spectrum(y, dt, legend=leg,
        title='Butterworth bandpass, fc = %.1f, %.1f' % fbp)

    # Brune deconvolution to Gaussian filter
    t = np.arange(n) * dt - n // 2 * dt
    x = signal.time_function('delta', t)
    leg, y = zip(
        (r'$\tau$',              signal.brune2gauss(x, dt, tau, tau)),
        (r'$\sqrt{2\ln 2}\tau$', signal.brune2gauss(x, dt, tau, tau*np.sqrt(2*np.log(2)))),
        (r'$\sqrt{2}\tau$',      signal.brune2gauss(x, dt, tau, tau*np.sqrt(2))),
        (r'$2\tau$',             signal.brune2gauss(x, dt, tau, tau*2)),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(4)
    signal.spectrum(y, dt, shift=True, legend=leg,
        title='Deconvolution, fc = %.1f, T = 0.5 / (pi * fc)' % flp)

    plt.ion()
    plt.show()
    return


# continue if command line
if __name__ == '__main__':
    test()

