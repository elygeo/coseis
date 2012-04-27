#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

import numpy as np
cimport numpy as np

def trinterp(x, f, t, xi, fi=None):
    """
    Definition: cst.interpolate.trinterp(x, f, t, xi, fi=None)

    2D linear interpolation of function values specified on triangular mesh.
  
    Parameters
    ----------
    x:  shape (2, M) array of vertex coordinates.
    f:  shape (M) array of function values at the vertices.
    t:  shape (3, N) array of vertex indices for the triangles.
    xi: shape (2, ...) array of coordinates for the interpolation points.

    Returns
    -------
    fi: Array of interpolated values, same shape as `xi[0]`.
    """

    # declarations
    cdef np.ndarray[double, ndim=1, mode='c'] x_, y_, f_, xi_, yi_, fi_
    cdef np.ndarray[int, ndim=1, mode='c'] i0_, i1_, i2_
    cdef double A00, A01, A10, A11, b0, b1, d
    cdef double l0, l1, l2, lmin, lmax
    cdef int i0, i1, i2, i, j, k, m, n

    # tolerance
    lmin = -0.000001
    lmax =  1.000001

    # input arrays
    x_  = np.ascontiguousarray(x[0], 'd')
    y_  = np.ascontiguousarray(x[1], 'd')
    f_  = np.ascontiguousarray(f, 'd')
    i0_ = np.ascontiguousarray(t[0], 'i')
    i1_ = np.ascontiguousarray(t[1], 'i')
    i2_ = np.ascontiguousarray(t[2], 'i')
    xi_ = np.ascontiguousarray(xi[0], 'd').reshape(-1)
    yi_ = np.ascontiguousarray(xi[1], 'd').reshape(-1)

    # output array
    if fi == None:
        fi_ = np.empty_like(xi_)
        fi_.fill(float('nan'))
    else:
        if fi.dtpe.char != 'd':
            raise ValueError('`fi` must be type double')
        if not fi.flags.contiguous:
            raise ValueError('`fi` must be contiguous')
        fi_ = fi.reshape(-1)

    # bounds check
    m = x_.shape[0]
    if any(i0_ >= m) or any(i1_ >= m) or any(i2_ >= m):
        raise ValueError('`t` indices out of bounds')

    # loop over interpolation points, then triangles
    k = 0
    m = xi_.shape[0]
    n = i0_.shape[0]
    for i in range(m):
        for j in range(n):

            # barycentric coordinates
            i0 = i0_[k]
            i1 = i1_[k]
            i2 = i2_[k]
            A00 = x_[i1] - x_[i0]
            A01 = x_[i2] - x_[i0]
            A10 = y_[i1] - y_[i0]
            A11 = y_[i2] - y_[i0]
            d = 1.0 / (A00 * A11 - A01 * A10)
            b0 = xi_[i] - x_[i0]
            b1 = yi_[i] - y_[i0]
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

    return fi_.reshape(xi[0].shape)

