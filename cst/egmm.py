#!/usr/bin/env ipython -wthread
"""
EGMM - Empirical Ground Motion Model
"""
import numpy as np

def cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb ):
    """
    2008 Campbell-Bozorgnia NGA ground motion relation

    Parameters
    ----------
        T :      Strong motion parameter ('PGA', 'PGV', 'PGD', SA period)
        M :      Moment magnitude
        R_RUP :  Closest distance to the coseismic rupture plane (km)
        R_JB :   Closest distance to the surface projection of the coseismic rupture
                 plane (Joyner-Boore distance, km)
        Z_TOR :  Depth to the top of the coseismic rupture plane (km)
        Z_25 :   Depth to the 2.5 km/s shear-wave velocity horizon (sediment depth, km)
        V_S30 :  Average shear-wave velocity in the top 30 m of the site profile (m/s)
        delta :  Average fault dip (degrees)
        lamb :   Average fault rake (degrees)

    Returns
    -------
         Y :      Median ground motion estimate
         sigmaT : Total standard deviation of ln(Y)

    Reference
    ---------
         Campbell, K., and Y. Bozorgnia (2007), Campbell-Bozorgnia NGA ground motion
         relations for the geometric mean horizontal component of peak and spectral
         ground motion parameters, Tech. Rep. PEER 2007/02, Pacific Earthquake
         Engineering Research Center.
    """
    M     = np.array( M )
    R_RUP = np.array( R_RUP )
    R_JB  = np.array( R_JB )
    Z_TOR = np.array( Z_TOR )
    Z_25  = np.array( Z_25 )
    V_S30 = np.array( V_S30 )
    delta = np.array( delta )
    lamb  = np.array( lamb )
    params = {
    'T':   (  'c0', 'c1',  'c2', 'c3',  'c4','c5', 'c6','c7', 'c8','c9','c10','c11','c12',   'k1',  'k2','k3','slY','tlY','sT','rho'),
    0.010: ( -1715,  500,  -530, -262, -2118, 170, 5600, 280, -120, 490, 1058,  40,  610,  865000, -1186, 1839, 478, 219, 526, 1000),
    0.020: ( -1680,  500,  -530, -262, -2123, 170, 5600, 280, -120, 490, 1102,  40,  610,  865000, -1219, 1840, 480, 219, 528,  999),
    0.030: ( -1552,  500,  -530, -262, -2145, 170, 5600, 280, -120, 490, 1174,  40,  610,  908000, -1273, 1841, 489, 235, 543,  989),
    0.050: ( -1209,  500,  -530, -267, -2199, 170, 5740, 280, -120, 490, 1272,  40,  610, 1054000, -1346, 1843, 510, 258, 572,  963),
    0.075: (  -657,  500,  -530, -302, -2277, 170, 7090, 280, -120, 490, 1438,  40,  610, 1086000, -1471, 1845, 520, 292, 596,  922),
    0.10:  (  -314,  500,  -530, -324, -2318, 170, 8050, 280,  -99, 490, 1604,  40,  610, 1032000, -1624, 1847, 531, 286, 603,  898),
    0.15:  (  -133,  500,  -530, -339, -2309, 170, 8790, 280,  -48, 490, 1928,  40,  610,  878000, -1931, 1852, 532, 280, 601,  890),
    0.20:  (  -486,  500,  -446, -398, -2220, 170, 7600, 280,  -12, 490, 2194,  40,  610,  748000, -2188, 1856, 534, 249, 589,  871),
    0.25:  (  -890,  500,  -362, -458, -2146, 170, 6580, 280,    0, 490, 2351,  40,  700,  654000, -2381, 1861, 534, 240, 585,  852),
    0.30:  ( -1171,  500,  -294, -511, -2095, 170, 6040, 280,    0, 490, 2460,  40,  750,  587000, -2518, 1865, 544, 215, 585,  831),
    0.40:  ( -1466,  500,  -186, -592, -2066, 170, 5300, 280,    0, 490, 2587,  40,  850,  503000, -2657, 1874, 541, 217, 583,  785),
    0.50:  ( -2569,  656,  -304, -536, -2041, 170, 4730, 280,    0, 490, 2544,  40,  883,  457000, -2669, 1883, 550, 214, 590,  735),
    0.75:  ( -4844,  972,  -578, -406, -2000, 170, 4000, 280,    0, 490, 2133,  77, 1000,  410000, -2401, 1906, 568, 227, 612,  628),
    1.0:   ( -6406, 1196,  -772, -314, -2000, 170, 4000, 255,    0, 490, 1571, 150, 1000,  400000, -1955, 1929, 568, 255, 623,  534),
    1.5:   ( -8692, 1513, -1046, -185, -2000, 170, 4000, 161,    0, 490,  406, 253, 1000,  400000, -1025, 1974, 564, 296, 637,  411),
    2.0:   ( -9701, 1600,  -978, -236, -2000, 170, 4000,  94,    0, 371, -456, 300, 1000,  400000,  -299, 2019, 571, 296, 643,  331),
    3.0:   (-10556, 1600,  -638, -491, -2000, 170, 4000,   0,    0, 154, -820, 300, 1000,  400000,     0, 2110, 558, 326, 646,  289),
    4.0:   (-11212, 1600,  -316, -770, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2200, 576, 297, 648,  261),
    5.0:   (-11684, 1600,   -70, -986, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2291, 601, 359, 700,  200),
    7.5:   (-12505, 1600,   -70, -656, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2517, 628, 428, 760,  174),
    10.0:  (-13087, 1600,   -70, -422, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2744, 667, 485, 825,  174),
    'PGA': ( -1715,  500,  -530, -262, -2118, 170, 5600, 280, -120, 490, 1058,  40,  610,  865000, -1186, 1839, 478, 219, 526, 1000),
    'PGV': (   954,  696,  -309,  -19, -2016, 170, 4000, 245,    0, 358, 1694,  92, 1000,  400000, -1955, 1929, 484, 203, 525,  691),
    'PGD': ( -5270, 1600,   -70,    0, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2744, 667, 485, 825,  174),
    }

    params = 0.001 * np.array( params[T] )
    n  = 1.18
    cc = 1.88
    c  = params[:13]
    k  = params[13:16]
    sigma_lnY, tau_lnY, sigmaT, rho = params[16:]
    sigma_lnAF  = 0.3
    sigma_lnGPA = 0.478 #FIXME
    sigma_lnY_B = np.sqrt( sigma_lnY ** 2 - sigma_lnAF ** 2 )
    sigma_lnA_B = np.sqrt( sigma_lnGPA ** 2 - sigma_lnAF ** 2 )

    f_mag = (
        c[0] +
        c[1] * M +
        c[2] * np.maximum( 0.0, M - 5.5 ) +
        c[3] * np.maximum( 0.0, M - 6.5 )
    )
    f_dis = (c[4] + c[5] * M) * np.log( np.sqrt( R_RUP * R_RUP + c[6] * c[6] ) )
    F_RV = np.zeros_like( lamb )
    F_NM = np.zeros_like( lamb )
    F_RV[ (  30 < lamb) & (lamb < 150) ] = 1.0
    F_NM[ (-150 < lamb) & (lamb < -30) ] = 1.0
    f_flt = c[7] * F_RV * min( 1.0, Z_TOR ) + c[8] * F_NM
    i = (R_JB > 0.0) & (Z_TOR >= 1.0)
    f_hng = np.maximum( R_RUP, np.sqrt( R_JB * R_JB + 1.0 ) )
    f_hng = (f_hng - R_JB) / f_hng
    f_hng[i] = (R_RUP[i] - R_JB[i]) / R_RUP[i]
    f_hng = ( c[9] * f_hng *
        np.minimum( 1.0, np.maximum( 0.0, 2.0 * M - 12.0 ) ) *
        np.maximum( 0.0, 1.0 - 0.05 * Z_TOR ) *
        np.minimum( 1.0, 4.5 - 0.05 * delta )
    )
    f_site = (c[10] + k[1] * n) * np.log( np.minimum( 1100.0, V_S30 ) / k[0] )
    i = V_S30 < k[0]
    lowvel = np.any( i )

    if lowvel:
        sigmaT = sigmaT * np.ones_like( V_S30 )
        V_1100 = 1100.0 * np.ones_like( V_S30 )
        A_1100 = cbnga( 'PGA', M, R_RUP, R_JB, Z_TOR, Z_25, V_1100, delta, lamb )[0]
        f_site[i] = (
            c[10] * np.log( V_S30[i] / k[0] ) +
            k[1] * (
                np.log( A_1100[i] + cc * (V_S30[i] / k[0]) ** n ) -
                np.log( A_1100[i] + cc )
            )
        ).astype( f_site.dtype )
        alpha = k[1] * A_1100 * (
            1.0 / (A_1100 + cc * (V_S30 / k[0]) ** n) -
            1.0 / (A_1100 + cc)
        )
        sigmaT2 = (
            tau_lnY ** 2 +
            sigma_lnY_B ** 2 +
            sigma_lnAF ** 2 +
            ( alpha * sigma_lnA_B ) ** 2 +
            2.0 * alpha * rho * sigma_lnY_B * sigma_lnA_B
        )
        sigmaT[i] = np.sqrt( sigmaT2[i] ).astype( sigmaT.dtype )

    f_sed = np.zeros_like( Z_25 )
    i = Z_25 < 1
    f_sed[i] = c[11] * (Z_25[i] - 1.0)
    i = Z_25 > 3
    f_sed[i] = c[12] * k[2] * np.exp( -0.75 ) * (
        1 - np.exp( -0.25 * (Z_25[i] - 3.0) ) )
    Y = np.exp( f_mag + f_dis + f_flt + f_hng + f_site + f_sed )

    if not lowvel:
        sigmaT = sigmaT * np.ones_like( Y )

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

    M = np.arange( 4.0, 8.501, 0.1 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    plt.figure( 1 )
    plt.clf()
    plt.plot( M, Y )
    plt.xlabel( 'M' )
    plt.ylabel( T )
    M = 5.5,

    V_S30 = np.arange( 180.0, 1500.1, 10.0 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    plt.figure( 2 )
    plt.clf()
    plt.plot( V_S30, sigma )
    plt.xlabel( '$V_{S30}$' )
    plt.ylabel( T )
    V_S30 = 760.0,

    Z_25 = np.arange( 0.0, 6.01, 0.1 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    plt.figure( 3 )
    plt.clf()
    plt.plot( Z_25, Y )
    plt.xlabel( '$Z_{2.5}$' )
    plt.ylabel( T )
    Z_25 = 1.0,

    TT = ( 0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3,
           0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0 )
    Y = []
    sigma = []
    for T in TT:
        tmp = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
        Y += [ tmp[0][0] ]
        sigma += [ tmp[1][0] ]

    plt.figure( 4 )
    plt.clf()
    plt.loglog( TT, Y )
    plt.xlabel( 'T' )
    plt.ylabel( 'SA' )

    plt.figure( 5 )
    plt.clf()
    plt.semilogx( TT, sigma )
    plt.xlabel( 'T' )
    plt.ylabel( '$\sigma$' )

    plt.draw()
    plt.show()

    return

# command line
if __name__ == '__main__':
    test()

