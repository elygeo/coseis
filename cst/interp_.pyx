"""
Interpolation functions
"""

import numpy as np
cimport numpy as np


def interp1(xlim, f, xi, fi=None, method='nearest'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    """
    cdef np.ndarray[double, ndim=1, mode='c'] f_, fi_
    cdef np.ndarray[double, ndim=2, mode='c'] xi_
    cdef double r, x, dx, x0, x1
    cdef double b0, b1
    cdef int n, nx, j

    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi

    f_ = np.ascontiguousarray(f, 'd')
    xi_ = np.ascontiguousarray(xi.reshape([-1, 3], 'd'))

    if fi is None:
        fi_ = np.empty_like(xi_[:, 0])
        fi_.fill(float('nan'))
    else:
        if fi.dtpe.char != 'd':
            raise ValueError('`fi` must be type double')
        if not fi.flags.contiguous:
            raise ValueError('`fi` must be contiguous')
        fi_ = fi.reshape(-1)

    x0, x1 = xlim
    nx = f.size
    dx = (nx - 1) / (x1 - x0)
    n = fi_.size

    if method == 'nearest':
        for i in range(n):
            x = xi_[i, 0]
            if x < x0 or x > x1:
                continue
            j = int(dx * (x - x0) + 0.5)
            r = f_[j]
            if r == r:
                fi_[i] = r
    elif method == 'linear':
        for i in range(n):
            x = xi_[i, 0]
            if x < x0 or x > x1:
                continue
            x = dx * (x - x0)
            j = int(x)
            j = min(j, nx - 2)
            b0 = 1.0 - x + j
            b1 = x - j
            r = b0 * f_[j] + b1 * f_[j + 1]
            if r == r:
                fi_[i] = r

    return fi_.reshape(xi.shape[..., 0])


def interp2(xlim, f, xi, fi=None, method='nearest'):
    """
    2D piecewise interpolation of function values specified on regular grid.
    """
    cdef np.ndarray[double, ndim=2, mode='c'] f_, xi_
    cdef np.ndarray[double, ndim=1, mode='c'] fi_
    cdef double r, x, y, dx, dy, x0, y0, x1, y1
    cdef double b0, b1, b2, b3
    cdef int n, nx, ny, j, k

    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi

    f_ = np.ascontiguousarray(f, 'd')
    xi_ = np.ascontiguousarray(xi.reshape([-1, 3], 'd'))

    if fi is None:
        fi_ = np.empty_like(xi_[:, 0])
        fi_.fill(float('nan'))
    else:
        if fi.dtpe.char != 'd':
            raise ValueError('`fi` must be type double')
        if not fi.flags.contiguous:
            raise ValueError('`fi` must be contiguous')
        fi_ = fi.reshape(-1)

    [x0, x1], [y0, y1] = xlim
    nx, ny = f.shape
    dx = (nx - 1) / (x1 - x0)
    dy = (ny - 1) / (y1 - y0)
    n = fi_.size

    if method == 'nearest':
        for i in range(n):
            x = xi_[i, 0]
            y = xi_[i, 1]
            if x < x0 or x > x1 or y < y0 or y > y1:
                continue
            j = int(dx * (x - x0) + 0.5)
            k = int(dy * (y - y0) + 0.5)
            r = f_[j, k]
            if r == r:
                fi_[i] = r
    elif method == 'linear':
        for i in range(n):
            x = xi_[i, 0]
            y = xi_[i, 1]
            if x < x0 or x > x1 or y < y0 or y > y1:
                continue
            x = dx * (x - x0)
            y = dy * (y - y0)
            j = int(x)
            k = int(y)
            j = min(j, nx - 2)
            k = min(k, ny - 2)
            b0 = (1.0 - x + j) * (1.0 - y + k)
            b1 = (1.0 - x + j) * (y - k)
            b2 = (x - j) * (1.0 - y + k)
            b3 = (x - j) * (y - k)
            r = (
                b0 * f_[j, k] + b1 * f_[j, k + 1] +
                b2 * f_[j + 1, k] + b3 * f_[j + 1, k + 1]
            )
            if r == r:
                fi_[i] = r

    return fi_.reshape(xi.shape[..., 0])


def interp3(xlim, f, xi, fi=None, method='nearest'):
    """
    3D piecewise interpolation of function values specified on regular grid.
    """
    cdef np.ndarray[double, ndim=3, mode='c'] f_
    cdef np.ndarray[double, ndim=2, mode='c'] xi_
    cdef np.ndarray[double, ndim=1, mode='c'] fi_
    cdef double r, x, y, z, dx, dy, dz, x0, y0, z0, x1, y1, z1
    cdef double b0, b1, b2, b3, b4, b5, b6, b7
    cdef int n, nx, ny, nz, j, k, l

    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi

    f_ = np.ascontiguousarray(f, 'd')
    xi_ = np.ascontiguousarray(xi.reshape([-1, 3], 'd'))

    if fi is None:
        fi_ = np.empty_like(xi_[:, 0])
        fi_.fill(float('nan'))
    else:
        if fi.dtpe.char != 'd':
            raise ValueError('`fi` must be type double')
        if not fi.flags.contiguous:
            raise ValueError('`fi` must be contiguous')
        fi_ = fi.reshape(-1)

    [x0, x1], [y0, y1], [z0, z1] = xlim
    nx, ny, nz = f.shape
    dx = (nx - 1) / (x1 - x0)
    dy = (ny - 1) / (y1 - y0)
    dz = (nz - 1) / (z1 - z0)
    n = fi_.size

    if method == 'nearest':
        for i in range(n):
            x = xi_[i, 0]
            y = xi_[i, 1]
            z = xi_[i, 2]
            if x < x0 or x > x1 or y < y0 or y > y1 or z < z0 or z > z1:
                continue
            j = int(dx * (x - x0) + 0.5)
            k = int(dy * (y - y0) + 0.5)
            l = int(dz * (z - z0) + 0.5)
            r = f_[j, k, l]
            if r == r:
                fi_[i] = r
    elif method == 'linear':
        for i in range(n):
            x = xi_[i, 0]
            y = xi_[i, 1]
            z = xi_[i, 2]
            if x < x0 or x > x1 or y < y0 or y > y1 or z < z0 or z > z1:
                continue
            x = dx * (x - x0)
            y = dy * (y - y0)
            z = dz * (z - z0)
            j = int(x)
            k = int(y)
            l = int(z)
            j = min(j, nx - 2)
            k = min(k, ny - 2)
            l = min(l, nz - 2)
            b0 = (1.0 - x + j) * (1.0 - y + k) * (1.0 - z + l)
            b1 = (1.0 - x + j) * (1.0 - y + k) * (z - l)
            b2 = (1.0 - x + j) * (y - k) * (1.0 - z + l)
            b3 = (1.0 - x + j) * (y - k) * (z - l)
            b4 = (x - j) * (1.0 - y + k) * (1.0 - z + l)
            b5 = (x - j) * (1.0 - y + k) * (z - l)
            b6 = (x - j) * (y - k) * (1.0 - z + l)
            b7 = (x - j) * (y - k) * (z - l)
            r = (
                b0 * f_[j, k, l] + b1 * f_[j, k, l + 1] +
                b2 * f_[j, k + 1, l] + b3 * f_[j, k + 1, l + 1] +
                b4 * f_[j + 1, k, l] + b5 * f_[j + 1, k, l + 1] +
                b6 * f_[j + 1, k + 1, l] + b7 * f_[j + 1, k + 1, l + 1]
            )
            if r == r:
                fi_[i] = r

    return fi_.reshape(xi.shape[..., 0])


def trinterp(x, f, t, xi, fi=None):
    """
    2D linear interpolation of function values specified on triangular mesh.
    x:  shape (M, 2) array of vertex coordinates.
    f:  shape (M) array of function values at the vertices.
    t:  shape (N, 3) array of vertex indices for the triangles.
    xi: shape (..., 2) array of coordinates for the interpolation points.
    Returns array of interpolated values, same shape as `xi[..., 0]`.
    """

    # declarations
    cdef np.ndarray[double, ndim=2, mode='c'] x_, xi_
    cdef np.ndarray[double, ndim=1, mode='c'] f_, fi_
    cdef np.ndarray[int, ndim=2, mode='c'] t_
    cdef double A00, A01, A10, A11, b0, b1, d
    cdef double l0, l1, l2, lmin, lmax
    cdef int i0, i1, i2, i, j, k, m, n

    # tolerance
    lmin = -0.000001
    lmax = 1.000001

    # input arrays
    x_ = np.ascontiguousarray(x, 'd')
    f_ = np.ascontiguousarray(f, 'd')
    t_ = np.ascontiguousarray(t, 'i')
    xi_ = np.ascontiguousarray(xi.reshape(-1), 'd')

    # output array
    if fi is None:
        fi_ = np.empty_like(xi_[:, 0])
        fi_.fill(float('nan'))
    else:
        if fi.dtpe.char != 'd':
            raise ValueError('`fi` must be type double')
        if not fi.flags.contiguous:
            raise ValueError('`fi` must be contiguous')
        fi_ = fi.reshape(-1)

    # bounds check
    m = x_.shape[0]
    if any(t_ >= m):
        raise ValueError('`t` indices out of bounds')

    # loop over interpolation points, then triangles
    k = 0
    m = xi_.shape[0]
    n = t_.shape[0]
    for i in range(m):
        for j in range(n):

            # barycentric coordinates
            i0 = t_[k, 0]
            i1 = t_[k, 1]
            i2 = t_[k, 2]
            A00 = x_[i1, 0] - x_[i0, 0]
            A01 = x_[i2, 0] - x_[i0, 0]
            A10 = x_[i1, 1] - x_[i0, 1]
            A11 = x_[i2, 1] - x_[i0, 1]
            d = A00 * A11 - A01 * A10

            # if zero area triangle, move to the next one
            if d == 0.0:
                print('Degenerate triange: %s of %s' % (k, n))
                if j % 2:
                    k = (n + k - j - 1) % n
                else:
                    k = (n + k + j + 1) % n
                continue
            else:
                d = 1.0 / d

            b0 = xi_[i, 0] - x_[i0, 0]
            b1 = xi_[i, 1] - x_[i0, 1]
            l1 = d * A11 * b0 - d * A01 * b1
            l2 = d * A00 * b1 - d * A10 * b0
            l0 = 1.0 - l1 - l2

            # if outside the triangle, move to the next one
            if (
               (l1 < lmin) | (l1 > lmax) |
               (l2 < lmin) | (l2 > lmax) |
               (l0 < lmin) | (l0 > lmax)
            ):
                if j % 2:
                    k = (n + k - j - 1) % n
                else:
                    k = (n + k + j + 1) % n
                continue

            # evaluate function
            fi_[i] = l0 * f_[i0] + l1 * f_[i1] + l2 * f_[i2]
            break

    return fi_.reshape(xi.shape[..., 0])
