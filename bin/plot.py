#!/usr/bin/env ipython -wthread
"""
Quick multi-purpose plotting.

Usage
-----
plot [options] <datafile>

Options
-------
-t <dtype>  NumpPy dtype string
-c <clim>   Set upper color scale limit to constant value.
-s          For image series, step through with mouse clicks.
"""
from __future__ import division, absolute_import, print_function, unicode_literals
import os, sys, getopt
import numpy as np
#import matplotlib
#matplotlib.rcParams['interactive'] = True
import matplotlib.pyplot as plt
import cst

def stats(f, msg=''):
    """
    Display statistic of a NumPy array f with optional message.
    """
    i = ~np.isnan(f)
    print(f[i].min(), f[i].max(), f[i].mean(), msg)
    return

def plot(*argv):
    """
    Quick multi-purpose plotting.
    """
    # options
    opts, files = getopt.getopt(argv, 'sc:t:')
    opts = dict(opts)
    clim = None
    if '-c' in opts:
        clim = float(opts['-c'])
        clim = -clim, clim

    # loop over files
    for file in files:

        # test for file
        if not os.path.exists(file):
            sys.exit('No such file: %s' % file)

        # options
        title = os.path.splitext(os.path.split(file)[-1])[0]
        delta = 1,
        dtype = 'f'
        if '-t' in opts:
            dtype = opts['-t'].replace('l', '<').replace('b', '>')

        # read text file
        if file.lower().endswith('.txt'):
            data = np.loadtxt(file).T
            shape = data.shape

        # read NumPy file
        elif file.lower().endswith('.npy'):
            data = np.load(file)
            shape = data.shape

        # read SAC file
        elif file.lower().endswith('.sac'):
            import obspy.core
            data = obspy.core.read(file)[0]
            delta = data.stats.delta,
            data = data.data
            shape = data.shape

        # read binary file with SORD metadata (if present)
        else:
            shape = 0,
            f = os.path.split(file)
            for i in range(1,len(f)):
                path = os.sep.join(f[:-i])
                tail = os.sep.join(f[i:])
                meta = os.path.join(path, 'meta.py')
                if os.path.exists(meta):
                    meta = cst.util.load(meta)
                    shape = meta.shapes[tail]
                    delta = meta.deltas[tail]
                    dtype = meta.dtype
                    break
            if len(shape) == 1:
                data = np.fromfile(file, dtype)
            elif len(shape) == 2:
                nn = shape[1], shape[0]
                n = shape[0] * shape[1]
                data = np.fromfile(file, dtype, n).reshape(nn)

        # XY plot or 2D image
        if len(shape) < 3:
            fig = plt.figure()
            ax = fig.add_subplot(111)
            if len(shape) == 1:
                stats(data, title)
                t = np.arange(data.size) * delta[0]
                ax.plot(t, data)
            elif len(shape) == 2 and shape[0] == 2:
                stats(data[0], title)
                stats(data[1], title)
                ax = fig.add_subplot(111)
                ax.plot(data[0], data[1])
            elif len(shape) == 2:
                stats(data, title)
                ax = fig.add_subplot(111)
                im = ax.imshow(data, interpolation='nearest')
                plt.colorbar(im)
                if clim:
                    im.set_clim(*clim)
            ax.set_title(title)
            fig.show()

        # 3D series of images
        else:
            fig = plt.figure()
            f1 = open(file)
            for it in range( shape[-1] ):
                nn = shape[1], shape[0]
                n = shape[0] * shape[1]
                data = np.fromfile(f1, dtype, n).reshape(nn)
                fig.clf()
                ax = fig.add_subplot(111)
                ax.set_title('%s %s' % (title, it * delta[-1]))
                stats(data, '%s %s' % (title, it * delta[-1]))
                im = ax.imshow(data, interpolation='nearest')
                fig.colorbar(im)
                if clim:
                    im.set_clim(*clim)
                fig.canvas.draw()
                fig.canvas.Update()
                fig.show()
                if '-s' in opts:
                    fig.ginput(1, 0, False)

# continue if command line
if __name__ == '__main__':
    from IPython.Shell import IPShellEmbed
    plot(*sys.argv[1:])
    #os.environ['PYTHONINSPECT'] = 'enable'
    #ipshell = IPShellEmbed()
    #ipshell()

