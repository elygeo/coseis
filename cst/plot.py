"""
Quick multi-purpose plotting from the command line or Python.
Reads text, binary, JSON, NumPy, or SAC files.
"""
import os
import json
import numpy as np
import matplotlib.pyplot as plt
from numpy.lib.npyio import format as npy


def stats(f, msg=''):
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


def main(
    files, dtype='f', shape=[], step=0, power=0, clim=[], transpose=False
):
    shape0 = shape
    dtype0 = dtype.replace('l', '<').replace('b', '>')
    fig = plt.figure(figsize=(12, 7.2))
    print('         Min          Max         Mean  Shape')
    for filename in files:
        dtype = dtype0
        shape = shape0
        title = os.path.split(filename)[-1]
        title = os.path.splitext(title)[0]
        if filename.lower().endswith('.txt'):
            data = np.loadtxt(filename)
            shape = data.shape
        elif filename.lower().endswith('.json'):
            data = np.asarray(json.load(filename))
            shape = data.shape
        elif filename.lower().endswith('.sac'):
            import obspy.core
            data = obspy.core.read(filename)[0].data
            shape = data.shape
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
        fig.clf()
        ax = fig.add_subplot(111)
        ax.set_title(title)
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
                    data = data[:, ::step]
                stats(data[0], title)
                stats(data[1], title)
                if power:
                    data = data[0], data[1] ** power
                ax.plot(data[0], data[1])
            else:
                if step:
                    data = data[::step, ::step]
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
                    data = data[::step, ::step]
                if transpose:
                    data = data.T
                stats(data, '%s %s' % (title, it))
                ax.set_title('%s %s' % (title, it))
                if power:
                    data = data ** power
                if it == 0:
                    im = ax.imshow(
                        data.T, origin='lower', interpolation='nearest')
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
