"""
Interpolation functions
"""

#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

import numpy as np
cimport numpy as np

def trinterp(x, f, t, xi, fi=None, no_data_val=float('nan')):
    """
    2D linear interpolation of function values specified on triangular mesh.

    x:  shape (2, M) array of vertex coordinates.
    f:  shape (M) array of function values at the vertices.
    t:  shape (3, N) array of vertex indices for the triangles.
    xi: shape (2, ...) array of coordinates for the interpolation points.
    Returns array of interpolated values, same shape as `xi[0]`.
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
    xi_ = np.ascontiguousarray(xi, 'd').reshape(-1)

    # output array
    if fi == None:
        fi_ = np.empty_like(xi_)
        fi_.fill(no_data_val)
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

    return fi_.reshape(xi[..., 0].shape)

