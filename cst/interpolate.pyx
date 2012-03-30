#cython: boundscheck=False
#cython: wraparound=False
#cython: cdivision=True

import numpy as np
cimport numpy as np

def trinterp(x, f, t, xi):
    """
    2D linear interpolation of function values specified on triangular mesh.
  
    Parameters
    ----------
    x: M x 2 array of vertex coordinates.
    f: M length array of function values at the vertices.
    t: N x 3 array of vertex indices for the triangles.
    xi: Array of coordinates for the interpolation points.

    Returns
    -------
    fi: Array of interpolated values, same shape as `xi`.
    """

    # declarations
    cdef np.ndarray[double, ndim=2, mode='c'] x_, xi_
    cdef np.ndarray[double, ndim=1, mode='c'] f_, fi_
    cdef np.ndarray[int, ndim=2, mode='c'] t_
    cdef double A00, A01, A10, A11, b0, b1, d
    cdef double l0, l1, l2, lmin, lmax
    cdef int i0, i1, i2, i, j, k, m, n

    # prepare arrays
    x_  = np.asfortranarray(x, 'd').T
    f_  = np.asfortranarray(f, 'd')
    t_  = np.asfortranarray(t, 'i').T
    xi_ = np.asfortranarray(xi, 'd').T.reshape((-1,2))
    fi_ = np.empty_like(xi_.T[0])
    fi_.fill(np.nan)

    # tolerance
    lmin = -0.000001
    lmax =  1.000001

    # loop over interpolation points, then triangles
    k = 0
    m = fi_.shape[0]
    n = t_.shape[0]
    for i in range(m):
        for j in range(n):
            if j % 2:
                k = (n + k + j) % n
            else:
                k = (n + k - j) % n
            i0 = t_[k,0]
            i1 = t_[k,1]
            i2 = t_[k,2]
            A00 = x_[i1,0] - x_[i0,0]
            A01 = x_[i2,0] - x_[i0,0]
            A10 = x_[i1,1] - x_[i0,1]
            A11 = x_[i2,1] - x_[i0,1]
            d  = 1.0 / (A00 * A11 - A01 * A10)
            b0 = xi_[i,0] - x_[i0,0]
            b1 = xi_[i,1] - x_[i0,1]
            l1 = d * A11 * b0 - d * A01 * b1
            l2 = d * A00 * b1 - d * A10 * b0
            l0 = 1.0 - l1 - l2
            if (
               (l1 < lmin) | (l1 > lmax) |
               (l2 < lmin) | (l2 > lmax) |
               (l0 < lmin) | (l0 > lmax)
            ):
                continue
            fi_[i] = l0 * f_[i0] + l1 * f_[i1] + l2 * f_[i2]
            break

    m, n = xi[0].shape
    return fi_.reshape([n, m]).T

