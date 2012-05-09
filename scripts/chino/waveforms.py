#!/usr/bin/env python
import os, imp
import numpy as np
import pyproj
import matplotlib.pyplot as plt
import obspy.core
#import obspy.signal, obspy.xseed
import cst

# parameters
chan = 'HN'
nsta = 8
duration = 50.0
lfilter = None
xoff = 4.0
vscale = 100.0
ysep = 0.35
ysep = 0.2
yoff = -20; lfilter = None,
yoff = -1; lfilter = (0.1, 0.25), 'bandpass', 2, -1
yoff = -2; lfilter = (0.1, 0.5), 'bandpass', 2, -1
yoff = -10; lfilter = (0.1, 1.0), 'bandpass', 2, -1

# filter
def filt(x, dt):
    x = cst.signal.filter(x, dt, *lfilter)
    return x

# windowed Fourier spectrum
def spectrum(x):
    n = x.size
    w = 0.5 - 0.5 * np.cos(np.arange(n) * 2 * np.pi / (n - 1))
    X = abs(np.fft.rfft(w * x)) * 2 / n
    return X

# metadata
path = os.path.join('run', 'sim')
path = 'tmp'
sims = 'ch0100sf', 'ch0100hf', 'ch0100gf'
sims = 'ch0050sf', 'ch0050hf', 'ch0050gf'
meta = os.path.join(path, sims[0], 'meta.py')
meta = imp.load_source('meta', meta)
duration0 = meta.shape[-1] * meta.delta[-1]
proj = pyproj.Proj(**meta.projection)
t0 = obspy.core.utcdatetime.UTCDateTime(meta.origin_time)

# stations
f = os.path.join('run', 'data', 'station-list.txt')
s = np.loadtxt(f, 'S9,f,f,f')
x, y = proj(s['f2'], s['f1'])

# material profiles
cvmclip = [0.0, 1.5, 0.5]
f = os.path.join('run', 'data') + os.sep
n = len(s)
cvm = 0.001 * np.array([
    np.fromfile(f + 'cvms-rho.bin', 'f'),
    np.fromfile(f + 'cvms-vp.bin', 'f'),
    np.fromfile(f + 'cvms-vs.bin', 'f'),
    np.fromfile(f + 'cvmh-rho.bin', 'f'),
    np.fromfile(f + 'cvmh-vp.bin', 'f'),
    np.fromfile(f + 'cvmh-vs.bin', 'f'),
    np.fromfile(f + 'cvmg-rho.bin', 'f'),
    np.fromfile(f + 'cvmg-vp.bin', 'f'),
    np.fromfile(f + 'cvmg-vs.bin', 'f'),
]).reshape([3,3,n,-1]).transpose([2,0,1,3])
cvmz = np.arange(cvm.shape[-1])

# sort by azimuth into groups, then by radius within group
i = 19
r = x * x + y * y
a = np.arctan2(y, x)
a = (a - a[i]) % (2.0 * np.pi)
i = a.argsort()
s = s[i]
r = r[i]
cvm = cvm[i]
n = nsta
station_groups = []
for i in range(0, len(s), n):
    s_ = s[i:i+n]
    r_ = r[i:i+n]
    c_ = cvm[i:i+n]
    j = r_.argsort()
    station_groups.append([s_[j],c_[j]])

# figure defaults
color_cycle=['k', 'r', 'b', 'g']
plt.rcdefaults()
plt.rc('font', size=8)
plt.rc('legend', fontsize=8)
plt.rc('axes', lw=0.5, color_cycle=color_cycle)
plt.rc('lines', lw=0.5, solid_joinstyle='round')
fig1 = plt.figure(None, (6.4, 8.0), 100, 'w')
fig1 = False

# loop over station groups
for igroup, group in enumerate(station_groups):

    # setup figure
    fig = plt.figure(None, (6.4, 9.0), 100, 'w')
    ax = fig.add_axes([0.0, 0.0, 1.0, 1.0])
    ax.axis('tight')
    ax.axis('off')
    ax.set_xlim([-xoff, 3 * duration + 3 * xoff])
    ax.set_ylim([(nsta + 0.2) * yoff, (ysep - 0.8) * yoff])
    x = 1.5 * duration + xoff
    y = -2.0 * yoff * ysep
    ax.text(x - duration - xoff, y, 'East-West',   ha='center', va='center')
    ax.text(x,                   y, 'North-South', ha='center', va='center')
    ax.text(x + duration + xoff, y, 'Vertical',    ha='center', va='center')
    y = len(group[0]) * yoff
    cst.plt.lengthscale(ax, [x - 25, x + 25], 2 * [y], label='%s s', backgroundcolor='w')

    # loop over stations
    for ista, sta in enumerate(group[0]):
        cvm = group[1][ista]
        name, x, y, z = sta['f0'], sta['f2'], sta['f1'], sta['f3']
        x, y = proj(x, y)
        z -= meta.depth
        spread = 0.00002 * (x * x + y * y + z * z) ** 0.5
        spread = 0.004 * (x * x + y * y) ** 0.25
        print(name)

        # separates
        if fig1:
            fig1.clf()

        # loop over channels
        for ichan in range(3):

            # data
            f = '.'.join([str(meta.event_id), name, chan + 'ENZ'[ichan], 'sac'])
            f = os.path.join('run', 'data', f)
            st = obspy.core.read(f)
            tr = st[0]
            dt = tr.stats.delta
            tr.data -= tr.data.mean()
            tr.data = filt(tr.data, dt)
            tr.data = dt * np.cumsum(tr.data)
            tr.trim(t0, t0 + duration0)
            vspec = spectrum(tr.data)
            tr.trim(t0, t0 + duration)
            v = tr.data
            n = v.size
            t = dt * np.arange(n)
            vmax = np.abs(v).max()

            # plot
            x = ichan * (duration + xoff)
            y = yoff * (ista % nsta)
            c = plt.rcParams['axes.color_cycle'][0]
            ax.plot(x + t, y + v * spread)
            if ichan == 0:
                a = '%s\n%.1f' % (name.split('.')[1], vmax)
                a = name.split('.')[1]
                ax.text(x, y - 0.05 * yoff, a, va='baseline', ha='center', color=c)
                a = '%.1f' % vmax
            else:
                a = '%.1f' % vmax
            ax.text(x, y + 0.05 * yoff, a, va='top', ha='center', color=c)

            # separates
            if fig1:
                ax1 = fig1.add_subplot(331 + 3 * ichan)
                ax2 = fig1.add_subplot(332 + 3 * ichan)
                ax3 = fig1.add_subplot(333 + 3 * ichan)
                ax1.set_title(['Density', '$V_P$', '$V_S$'][ichan])
                ax2.set_title(name + '-' + 'ENZ'[ichan])
                ax3.set_title(name + '-' + 'ENZ'[ichan])
                ax1.set_ylabel('Depth (m)')
                ax3.set_ylabel('Fourier amplitude')
                ax3.yaxis.tick_right()
                ax3.yaxis.set_label_position('right')
                ax2.plot(t, v)
                n = vspec.size
                f = np.arange(n) / (dt * 2 * (n - 1))
                ax3.loglog(f, vspec)
                ax1.set_ylim([cvmz[-1], 0])
                ax3.set_xlim([0.02, 2.0])
                ax3.set_ylim([1e-6, 1.0])
               
                if ichan == 2:
                   ax1.set_xlabel('Wave speed (km/s)')
                   ax2.set_xlabel('Ground velocity (m/s)')
                   ax3.set_xlabel('Frequecy (Hz)')

            # synthetics
            for isim, id_ in enumerate(sims):
                dt = meta.delta[-1]
                f = os.path.join(path, id_, 'out', name + '-v%s.bin' % (ichan + 1))
                v = np.fromfile(f, meta.dtype) * vscale
                #v = replace(v, dt)
                v = filt(v, dt)
                vspec = spectrum(v)
                n = min(v.size, int(duration / meta.delta[-1]))
                v = v[:n]
                t = dt * np.arange(n)
                vmax = np.abs(v).max()

                # plot
                x = ichan * (duration + xoff)
                y = yoff * ((ista % nsta) + (isim + 1) * ysep)
                c = plt.rcParams['axes.color_cycle'][isim + 1]
                ax.plot(x + t, y + v * spread)
                ax.text(x, y + 0.05 * yoff, '%.1f' % vmax, va='top', ha='center', color=c)

                # separates
                if fig1:
                    f = cvm[isim,ichan]
                    h = ax1.plot(f, cvmz, color=c)
                    h[0].set_dashes((2,1))
                    f = np.maximum(f, cvmclip[ichan])
                    ax1.plot(f, cvmz, color=c)
                    ax2.plot(t, v)
                    n = vspec.size
                    f = np.arange(n) / (dt * 2 * (n - 1))
                    ax3.loglog(f, vspec)

        # finish separate
        if fig1:
            f = os.path.join('run', 'plot', name.lower().replace('.', '-') + '.pdf')
            fig1.savefig(f, transparate=True)

    # finish figure
    fig.canvas.draw()
    if lfilter[0]:
        f = os.path.join('run', 'plot', 'waveform-%.0f-%s' % (1.0 / lfilter[0][1], igroup))
    else:
        f = os.path.join('run', 'plot', 'waveform-raw-%s' % igroup)
    fig.savefig(f + '.pdf', transparent=True)
    fig.savefig(f + '.png', dpi=100)
    fig.show()

