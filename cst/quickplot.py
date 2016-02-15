#!/usr/bin/env python
"""
Quick multi-purpose plotting.

--dtype=str        NumpPy data type
--shape=[int,...]  Array dimensions
--clim=[val,val]   Color scale limit
--power=val        Exponent power applied to data
--step=int         Decimate data
--transpose        Transpose data

"""
import os, sys, json
import numpy as np
from numpy.lib.npyio import format as npy
import matplotlib.pyplot as plt

def stats(f, msg=''):
    """
    Display statistic of a NumPy array f with optional message.
    """
    if f.size == 0:
        rmin = float('nan')
        rmax = float('nan')
        rmean = float('nan')
    else:
        i = ~np.isnan(f)
        rmin = f[i].min().copy()
        rmax = f[i].max().copy()
        rmean = f[i].astype('d').mean()
    print('%12g %12g %12g  %s  %s' % (rmin, rmax, rmean, f.shape, msg))
    return

def quickplot(*files, dtype='f', shape=[], step=None, power=None, clim=None, transpose=None):
    """
    Quick multi-purpose plotting.
    """

    # defaults
    shape0 = shape
    dtype0 = dtype.replace('l', '<').replace('b', '>')

    # init
    fig = plt.figure(figsize=(12, 7.2))
    print('         Min          Max         Mean  Shape')

    # loop over files
    for filename in files:

        dtype = dtype0
        shape = shape0
        title = os.path.split(filename)[-1]
        title = os.path.splitext(title)[0]

        # read text
        if filename.lower().endswith('.txt'):
            data = np.loadtxt(filename).T
            shape = data.shape

        # read SAC
        elif filename.lower().endswith('.sac'):
            import obspy.core
            data = obspy.core.read(filename)[0].data
            shape = data.shape

        # read NumPy
        elif filename.lower().endswith('.npy'):
            fh = open(filename, 'rb')
            version = npy.read_magic(fh)
            shape, fcont, dtype = npy._read_array_header(fh, version)
            if not fcont:
                shape = shape[::-1]
            if len(shape) < 3:
                fh.close()
                data = np.load(filename)
                shape = data.shape

        # read binary
        elif filename.lower().endswith('.bin'):
            if len(shape) < 3:
                data = np.fromfile(filename, dtype)
                if shape:
                    data = data.reshape(shape[::-1]).T
                else:
                    shape = data.shape
            else:
                fh = open(filename, 'rb')

        else:
            raise Exception('unknown file type: ' + filename)

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
            ax.plot(data)
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
            m = shape[2]
            for i in shape[3:]:
                m *= i
            for it in range(m):
                data = np.fromfile(fh, dtype, n)
                data = data.reshape(shape[1::-1]).T
                if step:
                    data = data[::step,::step]
                if transpose:
                    data = data.T
                stats(data, '%s %s' % (title, it))
                ax.set_title('%s %s' % (title, it))
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

def command_line():
    args = {}
    files = []
    for k in sys.argv[1:]:
        if k.startswith('-'):
            k = k.lstrip('-')
            if '=' in k:
                k, v = k.split('=')
                if len(v) and not v[0].isalpha():
                    v = json.loads(v)
                args[k] = v
            else:
                args[k] = True
        else:
            files.append(k)
    quickplot(*files, **args)

if __name__ == '__main__':
    command_line()

