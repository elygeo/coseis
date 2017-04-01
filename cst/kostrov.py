"""
Kostrov circular expanding crack analytical solution.
"""
import numpy


def cee_integrand(x, a2, b2):
    return (
        ((x + 0.5 * b2) ** 2.0 - x * numpy.sqrt((x + b2) * (x + a2))) /
        ((x + 1.0) * (x + 1.0) * numpy.sqrt(x + b2))
    )


def cee_integral(a2, b2):
    import scipy.integrate
    x = scipy.integrate.quad(cee_integrand, 0.0, float('inf'), args=(a2, b2))
    return x[0]


def cee(a, b):
    """
    a: Ratio of rupture to P-wave velocity, vrup/vp.
    b: Ratio of rupture to S-wave velocity, vrup/vs.
    """
    a2 = a * a
    b2 = b * b
    f = numpy.vectorize(cee_integral)
    d = f(a2, b2) + 0.25 * b2 * (b + numpy.arccos(b) / numpy.sqrt(1.0 - b2))
    return b * b2 / d


def slip_rate(rho, vp, vs, vrup, dtau, r, t, C=None):
    """
    rho: density
    vp: P-wave speed
    vs: S-wave speed
    vrup: rupture velocity
    dtau: stress drop
    r: hypocenter distance
    t: array of reduced-time samples (t=0 is rupture arrival time).
    C: optional C parameter from Dahlen (1974) Eqn (44).
       If not supplied, C is computed from vrup, vp and vs.
    """
    t0 = r / vrup
    if C is None:
        C = cee(vrup / vp, vrup / vs)
    v = C * dtau / (rho * vs) * (t + t0) / numpy.sqrt(t * (t + 2.0 * t0))
    return v
