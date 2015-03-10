#!/usr/bin/env python
"""
Quick multi-purpose plotting.

Usage
-----
plot [options] <datafile>

Options
-------
-c <clim>      Set upper color scale limit to constant value.
-d <dtype>     NumpPy dtype string
-p <exponent>  Eponent power applied to data
-s <step>      Decimate data
-t             Transpose data
"""
import os, sys, json, getopt
import numpy as np
from numpy.lib.npyio import format as npy
import matplotlib.pyplot as plt

def stats(f, msg=''):
    """
    Display statistic of a NumPy array f with optional message.
    """
    if f.size > 0:
        i = ~np.isnan(f)
        rmin = f[i].min().copy()
        rmax = f[i].max().copy()
        rmean = f[i].astype('d').mean()
    else:
        rmin = float('nan')
        rmax = float('nan')
        rmean = float('nan')
    print('%12g %12g %12g  %s  %s' % (rmin, rmax, rmean, f.shape, msg))
    return

def plot(*argv):
    """
    Quick multi-purpose plotting.
    """
    # options
    opts, args = getopt.getopt(argv, 'c:d:p:s:t')
    opts = dict(opts)
    power = None
    step = None
    clim = None
    transpose = '-t' in opts
    if '-p' in opts:
        power = float(opts['-p'])
    if '-s' in opts:
        step = int(opts['-s'])
    if '-c' in opts:
        clim = float(opts['-c'])
        clim = -clim, clim

    # init
    fig = plt.figure(figsize=(12, 7.2))
    print('         Min          Max         Mean  Shape')

    # loop over files
    for filename in args:

        # options
        title = os.path.splitext(os.path.split(filename)[-1])[0]
        delta = None
        dtype = 'f'
        if '-d' in opts:
            dtype = opts['-d'].replace('l', '<').replace('b', '>')

        # read text file
        if filename.lower().endswith('.txt'):
            data = np.loadtxt(filename).T
            shape = data.shape

        # read SAC file
        elif filename.lower().endswith('.sac'):
            import obspy.core
            data = obspy.core.read(filename)[0]
            delta = data.stats.delta,
            data = data.data

        # read NumPy file with metadata (if present)
        elif filename.lower().endswith('.npy'):
            f = os.path.split(filename)
            for i in range(1, len(f)):
                path = os.sep.join(f[:-i])
                tail = os.sep.join(f[i:])[:-4] + '.bin'
                meta = os.path.join(path, 'meta.json')
                if os.path.exists(meta):
                    meta = json.load(open(meta))
                    if 'deltas' in meta:
                        if tail in meta['deltas']:
                            delta = meta['deltas'][tail]
                    elif 'delta' in meta:
                        delta = meta['delta']
                    break
            fh = open(filename, 'rb')
            version = npy.read_magic(fh)
            shape, fcont, dtype = npy._read_array_header(fh, version)
            if not fcont:
                shape = shape[::-1]
            if len(shape) < 3:
                fh.close()
                data = np.load(filename)
                shape = data.shape

        # read binary file with metadata (if present)
        else:
            shape = []
            f = os.path.split(filename)
            for i in range(1, len(f)):
                path = os.sep.join(f[:-i])
                tail = os.sep.join(f[i:])
                meta = os.path.join(path, 'meta.json')
                if os.path.exists(meta):
                    meta = json.load(open(meta))
                    if dtype in meta:
                        dtype = meta['dtype']
                    if 'deltas' in meta:
                        if tail in meta['deltas']:
                            delta = meta['deltas'][tail]
                    elif 'delta' in meta:
                        delta = meta['delta']
                    if 'shapes' in meta:
                        if tail in meta['shapes']:
                            shape = meta['shapes'][tail]
                    elif 'shape' in meta:
                        shape = meta['shape']
                    break
            if len(shape) < 3:
                if shape:
                    data = np.fromfile(filename, dtype).reshape(shape[::-1]).T
                else:
                    data = np.fromfile(filename, dtype)
                    shape = data.shape
            else:
                fh = open(filename, 'rb')

        # meta
        if len(shape) > 3:
            sys.exit('more than 3 dimensions not supported')
        if delta == None:
            delta = len(shape) * [1]

        # setup figure
        fig.clf()
        ax = fig.add_subplot(111)
        ax.set_title(title)

        # plot
        if len(shape) == 1:
            if step:
                data = data[::step]
            stats(data, title)
            if power:
                data = data ** power
            x = np.arange(data.size) * delta[0]
            ax.plot(x, data)
        elif len(shape) == 2:
            if transpose or shape[1] == 2:
                data = data.T
                shape = data.shape
            if shape[0] == 2:
                if step:
                    data = data[:,::step]
                stats(data[0], title)
                stats(data[1], title)
                if power:
                    data = data[0], data[1] ** power
                ax.plot(data[0], data[1])
            else:
                if step:
                    data = data[::step,::step]
                stats(data, title)
                if power:
                    data = data ** power
                im = ax.imshow(data.T, origin='lower', interpolation='nearest')
                plt.colorbar(im, orientation='horizontal')
                if clim:
                    im.set_clim(*clim)
        else:
            n = shape[0] * shape[1]
            for it in range(shape[2]):
                data = np.fromfile(fh, dtype, n).reshape(shape[1::-1]).T
                if step:
                    data = data[::step,::step]
                if transpose:
                    data = data.T
                stats(data, '%s %s' % (title, it * delta[2]))
                ax.set_title('%s %s' % (title, it * delta[2]))
                if power:
                    data = data ** power
                if it == 0:
                    im = ax.imshow(data.T, origin='lower', interpolation='nearest')
                    fig.colorbar(im, orientation='horizontal')
                else:
                    im.set_array(data.T)
                if clim:
                    im.set_clim(*clim)
                else:
                    im.autoscale()
                fig.show()
                fig.canvas.draw()
                fig.ginput(1, 0, False)
        fig.canvas.draw()
        fig.ginput(1, 0, False)

# continue if command line
if __name__ == '__main__':
    plot(*sys.argv[1:])

