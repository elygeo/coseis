#!/usr/bin/env python3
import math
import cst.dsp
import numpy as np
import matplotlib.pyplot as plt


def spectrum(
    h, dt=1.0, shift=False, tzoom=10.0, db=None,
    legend=None, title='Forier spectrum', axes=None
):
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
        fig.subplots_adjust(
            left=0.125, right=0.975,
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
    n = 3200
    dt = 0.002
    fbp = 2.0, 8.0
    flp = 3.0
    tau = 0.5 / (math.pi * flp)
    scale = n // 2 * dt

    # filter comparison
    t = np.arange(n) * dt - n // 2 * dt
    x = cst.dsp.time_function('delta', t)
    leg, y = zip(
        ('Butter 1x2', cst.dsp.filter(x, dt, flp, 'lowpass', 1, 1)),
        ('Butter 2x2',  cst.dsp.filter(x, dt, flp, 'lowpass', 2, 1)),
        ('Butter 2x-2', cst.dsp.filter(x, dt, flp, 'lowpass', 2, -1)),
        ('Hann filter',  cst.dsp.filter(x, dt, flp, 'hann', 0, 0)),
        ('Brune',  cst.dsp.time_function('brune', t, tau)),
        (r'Ga $\sqrt{2\ln 2}\tau$',
            cst.dsp.time_function('gaussian', t, tau * np.sqrt(2*np.log(2)))),
        (r'Decon $\sqrt{2}\tau$',
            cst.dsp.brune2gauss(x, dt, tau, tau * np.sqrt(2))),
        # ('Hann', cst.dsp.time_function('hann', t, tau)),
        # ('Ricker1',
        #   cst.dsp.time_function('ricker1', t - 0.5 * dt, tau).cumsum() * dt),
        # ('Ricker2',
        #     cst.dsp.time_function('ricker2', t - dt, tau).cumsum().cumsum() *
        #     dt * dt),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(0)
    t = 'fc = %.1f, T = 0.5 / (pi * fc)' % flp
    spectrum(y, dt, shift=True, tzoom=5, legend=leg, title=t)

    # Butterworth lowpass
    t = np.arange(n) * dt - n // 2 * dt
    x = cst.dsp.time_function('delta', t)
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
    t = 'Butterworth lowpass, fc = %.1f' % flp
    spectrum(y, dt, shift=True, tzoom=5, legend=leg, title=t)

    # Butterworth bandpass
    t = np.arange(n) * dt
    x = cst.dsp.time_function('delta', t)
    leg, y = zip(
        ('2 pole ',    filter(x, dt, fbp, 'bandpass', 2, 0)),
        ('4 pole ',    filter(x, dt, fbp, 'bandpass', 4, 0)),
        ('1 pole x2 ', filter(x, dt, fbp, 'bandpass', 1, 1)),
        ('2 pole x2',  filter(x, dt, fbp, 'bandpass', 2, 1)),
    )
    y = np.asarray(y) * scale
    plt.figure(3)
    t = 'Butterworth bandpass, fc = %.1f, %.1f' % fbp
    spectrum(y, dt, legend=leg, title=t)

    # Brune deconvolution to Gaussian filter
    t = np.arange(n) * dt - n // 2 * dt
    x = cst.dsp.time_function('delta', t)
    leg, y = zip(
        (r'$\tau$', cst.dsp.brune2gauss(x, dt, tau, tau)),
        (r'$\sqrt{2\ln 2}\tau$',
            cst.dsp.brune2gauss(x, dt, tau, tau*np.sqrt(2 * np.log(2)))),
        (r'$\sqrt{2}\tau$', cst.dsp.brune2gauss(x, dt, tau, tau * np.sqrt(2))),
        (r'$2\tau$', cst.dsp.brune2gauss(x, dt, tau, tau * 2)),
    )
    y = np.asarray(y) * scale
    y = np.fft.ifftshift(y, axes=[-1])
    plt.figure(4)
    t = 'Deconvolution, fc = %.1f, T = 0.5 / (pi * fc)' % flp
    spectrum(y, dt, shift=True, legend=leg, title=t)

    plt.ion()
    plt.show()
    return

if __name__ == '__main__':
    test()
