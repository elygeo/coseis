"""
Empirical Ground Motion Model (EGMM).
"""
import os
import json
import numpy as np


def cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb):
    """
    2008 Campbell-Bozorgnia NGA ground motion relation

    Parameters:

    T:  Strong motion parameter ('PGA', 'PGV', 'PGD', SA period)
    M:  Moment magnitude
    R_RUP:  Closest distance to the coseismic rupture plane (km)
    R_JB:   Closest distance to the surface projection of the coseismic rupture
            plane (Joyner-Boore distance, km)
    Z_TOR:  Depth to the top of the coseismic rupture plane (km)
    Z_25:   Depth to 2.5 km/s shear-wave velocity horizon (sediment depth, km)
    V_S30:  Average shear-wave velocity in top 30 m of the site profile (m/s)
    delta:  Average fault dip (degrees)
    lamb:   Average fault rake (degrees)

    Returns:

    Y:  Median ground motion estimate
    sigmaT:  Total standard deviation of ln(Y)

    Reference:

    Campbell, K., and Y. Bozorgnia (2007), Campbell-Bozorgnia NGA ground motion
    relations for the geometric mean horizontal component of peak and spectral
    ground motion parameters, Tech. Rep. PEER 2007/02, Pacific Earthquake
    Engineering Research Center.
    """
    global params
    try:
        params
    except Exception:
        f = os.path.dirname(__file__)
        f = os.path.dirname(f)
        f = os.path.join(f, 'data', 'CBNGA.json')
        params = json.load(open(f))

    M = np.asarray(M)
    R_RUP = np.asarray(R_RUP)
    R_JB = np.asarray(R_JB)
    Z_TOR = np.asarray(Z_TOR)
    Z_25 = np.asarray(Z_25)
    V_S30 = np.asarray(V_S30)
    delta = np.asarray(delta)
    lamb = np.asarray(lamb)

    for line in params:
        if line[0] == T:
            (
                c0, c1, c2, c3, c4, c5, c6, c7,
                c8, c9, c10, c11, c12, k1, k2, k3,
                sigma_lnY, tau_lnY, sigmaT, rho
            ) = (0.001 * i for i in line[1:])
    n = 1.18
    cc = 1.88
    sigma_lnAF = 0.3
    sigma_lnGPA = 0.478  # FIXME
    sigma_lnY_B = np.sqrt(sigma_lnY ** 2 - sigma_lnAF ** 2)
    sigma_lnA_B = np.sqrt(sigma_lnGPA ** 2 - sigma_lnAF ** 2)

    f_mag = (
        c0 + c1 * M +
        c2 * np.maximum(0.0, M - 5.5) +
        c3 * np.maximum(0.0, M - 6.5)
    )

    f_dis = (c4 + c5 * M) * np.log(np.sqrt(R_RUP * R_RUP + c6 * c6))
    F_RV = np.zeros_like(lamb)
    F_NM = np.zeros_like(lamb)
    F_RV[(30 < lamb) & (lamb < 150)] = 1.0
    F_NM[(-150 < lamb) & (lamb < -30)] = 1.0
    f_flt = c7 * F_RV * min(1.0, Z_TOR) + c8 * F_NM
    i = (R_JB > 0.0) & (Z_TOR >= 1.0)
    f_hng = np.maximum(R_RUP, np.sqrt(R_JB * R_JB + 1.0))
    f_hng = (f_hng - R_JB) / f_hng
    f_hng[i] = (R_RUP[i] - R_JB[i]) / R_RUP[i]
    f_hng = (
        c9 * f_hng *
        np.minimum(1.0, np.maximum(0.0, 2.0 * M - 12.0)) *
        np.maximum(0.0, 1.0 - 0.05 * Z_TOR) *
        np.minimum(1.0, 4.5 - 0.05 * delta)
    )
    f_site = (c10 + k2 * n) * np.log(np.minimum(1100.0, V_S30) / k1)
    i = V_S30 < k1
    lowvel = np.any(i)

    if lowvel:
        sigmaT = sigmaT * np.ones_like(V_S30)
        V_1100 = 1100.0 * np.ones_like(V_S30)
        A_1100 = cbnga(
            'PGA', M, R_RUP, R_JB, Z_TOR, Z_25, V_1100, delta, lamb
        )[0]
        x = (
            c10 * np.log(V_S30 / k1) +
            k2 * (
                np.log(A_1100 + cc * (V_S30 / k1) ** n) -
                np.log(A_1100 + cc)
            )
        ).astype(f_site.dtype)
        if len(i) == 1:  # FIXME could broadcasting work here somehow?
            f_site = x
        elif len(f_site) == 1:
            x[i] = f_site[0]
            f_site = x
        else:
            f_site[i] = x[i]
        alpha = k2 * A_1100 * (
            1.0 / (A_1100 + cc * (V_S30 / k1) ** n) -
            1.0 / (A_1100 + cc)
        )
        sigmaT2 = np.sqrt(
            tau_lnY ** 2 +
            sigma_lnY_B ** 2 +
            sigma_lnAF ** 2 +
            (alpha * sigma_lnA_B) ** 2 +
            2.0 * alpha * rho * sigma_lnY_B * sigma_lnA_B
        ).astype(sigmaT.dtype)
        if len(i) == 1:
            sigmaT = sigmaT2
        elif len(sigmaT) == 1:
            sigmaT2[i] = sigmaT[0]
            sigmaT = sigmaT2
        else:
            sigmaT[i] = sigmaT2[i]

    f_sed = np.zeros_like(Z_25)
    i = Z_25 < 1
    f_sed[i] = c11 * (Z_25[i] - 1.0)
    i = Z_25 > 3
    f_sed[i] = c12 * k3 * np.exp(-0.75) * (
        1 - np.exp(-0.25 * (Z_25[i] - 3.0)))
    Y = np.exp(f_mag + f_dis + f_flt + f_hng + f_site + f_sed)

    if not lowvel:
        sigmaT = sigmaT * np.ones_like(Y)

    return Y, sigmaT


def test():
    """
    Test CBNGA for comparison with OpenSHA Attenuation Relationship Plotter
    """
    import matplotlib.pyplot as plt

    T = 10
    T = 1
    T = 0.1
    T = 0.01
    T = 'PGD'
    T = 'PGV'
    T = 'PGA'

    M = 5.5,
    R_RUP = 0.0,
    R_JB = 0.0,
    Z_TOR = 0.0,
    Z_25 = 1.0,
    V_S30 = 760.0,
    delta = 90.0,
    lamb = 0.0,

    M = np.arange(4.0, 8.501, 0.1)
    Y, sigma = cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)

    plt.figure(1)
    plt.clf()
    plt.plot(M, Y)
    plt.xlabel('M')
    plt.ylabel(T)

    M = 5.5,
    V_S30 = np.arange(180.0, 1500.1, 10.0)
    Y, sigma = cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)

    plt.figure(2)
    plt.clf()
    plt.plot(V_S30, sigma)
    plt.xlabel('$V_{S30}$')
    plt.ylabel(T)

    V_S30 = 760.0,
    Z_25 = np.arange(0.0, 6.01, 0.1)
    Y, sigma = cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)

    plt.figure(3)
    plt.clf()
    plt.plot(Z_25, Y)
    plt.xlabel('$Z_{2.5}$')
    plt.ylabel(T)

    Z_25 = 1.0,
    TT = (
        0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3,
        0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0
    )
    Y = []
    sigma = []
    for T in TT:
        tmp = cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)
        Y += [tmp[0][0]]
        sigma += [tmp[1][0]]

    plt.figure(4)
    plt.clf()
    plt.loglog(TT, Y)
    plt.xlabel('T')
    plt.ylabel('SA')

    plt.figure(5)
    plt.clf()
    plt.semilogx(TT, sigma)
    plt.xlabel('T')
    plt.ylabel('$\sigma$')

    plt.draw()
    plt.ion()
    plt.show()

    return


if __name__ == '__main__':
    test()
