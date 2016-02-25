"""
Seismic source tools.
"""
import numpy as np


def magarea(A):
    """
    Various earthquake magnitude area relations.
    """
    A = np.array(A, copy=False, ndmin=1)
    i = A > 537.0
    Mw = 3.98 + np.log10(A)
    Mw[i] = 3.07 + 4.0 / 3.0 * np.log10(A)
    Mw = {
        'Hanks2008': Mw,
        'EllsworthB2003': 4.2 + np.log10(A),
        'Somerville2006': 3.87 + 1.05 * np.log10(A),
        'Wells1994': 3.98 + 1.02 * np.log10(A),
    }
    return Mw


def areamag(Mw):
    """
    Various inverse earthquake magnitude area relations.
    """
    Mw = np.array(Mw, copy=False, ndmin=1)
    A = 10 ** (Mw - 3.98)
    i = A > 537.0
    A[i] = 10 ** ((Mw - 3.07) * 3.0 / 4.0)
    A = {
        'Hanks2008': A,
        'EllsworthB2003': 10 ** (Mw - 4.2),
        'Somerville2006': 10 ** ((Mw - 3.87) / 1.05),
        'Wells1994': 10 ** ((Mw - 3.98) / 1.02),
    }
    return A


def mw(moment, units='mks'):
    """
    Moment magnitude
    """
    if units == 'mks':
        m = (np.log10(moment) - 9.05) / 1.5
    else:
        m = (np.log10(moment) - 16.05) / 1.5
    return m
