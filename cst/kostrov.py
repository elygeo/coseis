#!/usr/bin/env python
import numpy as np
"""
Analytical solution for a circular crack expanding at a uniform rupture
velocity.

See ../scritps/kostrov/ for example usage.
"""

def cee_integrand(x, a2, b2):
    return (
        ((x + 0.5 * b2) ** 2.0 - x * np.sqrt((x + b2) * (x + a2))) /
        ((x + 1.0) * (x + 1.0) * np.sqrt(x + b2))
    )

def cee_integral(a2, b2):
    from scipy import integrate
    return integrate.quad(cee_integrand, 0.0, np.Inf, args=(a2, b2))[0]

def cee(a, b):
    """
    Parameters
    ----------
        a : Ratio of rupture to P-wave velocity, vrup / vp.
        b : Ratio of rupture to S-wave velocity, vrup / vs.
    """
    a2 = a * a
    b2 = b * b
    f = np.vectorize(cee_integral)
    d = f(a2, b2) + 0.25 * b2 * (b + np.arccos(b) / np.sqrt(1.0 - b2))
    return b * b2 / d

def slip_rate(rho, vp, vs, vrup, dtau, r, t):
    """
    Parameters
    ----------
        rho : density
        vp : P-wave speed
        vs : S-wave speed
        vrup : rupture velocity
        dtau : stress drop
        r : hypocenter distance
        t : array of reduced-time samples (t=0 is rupture arrival time).
    """
    t0 = r / vrup
    C = cee(vrup / vp, vrup / vs)
    v = C * dtau / (rho * vs) * (t + t0) / np.sqrt(t * (t + 2.0 * t0))
    return v

