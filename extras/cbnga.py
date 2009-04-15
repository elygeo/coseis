#!/usr/bin/env python

def cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb ):
    """
    CBNGA - 2007 Campbell-Bozorgnia NGA ground motion relation

    Arguments
        T:      Strong motion parameter ('PGA', 'PGV', 'PGD', SA period)
        M:      Moment magnitude
        R_RUP:  Closest distance to the coseismic rupture plane (km)
        R_JB:   Closest distance to the surface projection of the coseismic rupture
                plane (Joyner-Boore distance, km)
        Z_TOR:  Depth to the top of the coseismic rupture plane (km)
        Z_25:   Depth to the 2.5 km/s shear-wave velocity horizon (sediment depth, km)
        V_S30:  Average shear-wave velocity in the top 30 m of the site profile (m/s)
        delta:  Average fault dip (degrees)
        lamb:   Average fault rake (degrees)

    Output
         Y:      Median ground motion estimate
         sigmaT: Total standard deviation of ln(Y)

    Reference
         Campbell, K., and Y. Bozorgnia (2007), Campbell-Bozorgnia NGA ground motion
         relations for the geometric mean horizontal component of peak and spectral
         ground motion parameters, Tech. Rep. PEER 2007/02, Pacific Earthquake
         Engineering Research Center.
    """
    import numpy

    params = {
    'T':   (   'c0', 'c1',  'c2', 'c3',  'c4','c5', 'c6','c7', 'c8','c9','c10','c11','c12',   'k1',  'k2','k3','slY','tlY','sT','ps', 'pt' ),
    0.010: (  -1715,  500,  -530, -262, -2118, 170, 5600, 280, -120, 490, 1058,  40,  610,  865000, -1186, 1839, 478, 219, 526, 1000, 1000 ),
    0.020: (  -1680,  500,  -530, -262, -2123, 170, 5600, 280, -120, 490, 1102,  40,  610,  865000, -1219, 1840, 480, 219, 528,  999,  994 ),
    0.030: (  -1552,  500,  -530, -262, -2145, 170, 5600, 280, -120, 490, 1174,  40,  610,  908000, -1273, 1841, 489, 235, 543,  989,  979 ),
    0.050: (  -1209,  500,  -530, -267, -2199, 170, 5740, 280, -120, 490, 1272,  40,  610, 1054000, -1346, 1843, 510, 258, 572,  963,  927 ),
    0.075: (   -657,  500,  -530, -302, -2277, 170, 7090, 280, -120, 490, 1438,  40,  610, 1086000, -1471, 1845, 520, 292, 596,  922,  880 ),
    0.100: (   -314,  500,  -530, -324, -2318, 170, 8050, 280,  -99, 490, 1604,  40,  610, 1032000, -1624, 1847, 531, 286, 603,  898,  871 ),
    0.150: (   -133,  500,  -530, -339, -2309, 170, 8790, 280,  -48, 490, 1928,  40,  610,  878000, -1931, 1852, 532, 280, 601,  890,  885 ),
    0.200: (   -486,  500,  -446, -398, -2220, 170, 7600, 280,  -12, 490, 2194,  40,  610,  748000, -2188, 1856, 534, 249, 589,  871,  913 ),
    0.250: (   -890,  500,  -362, -458, -2146, 170, 6580, 280,    0, 490, 2351,  40,  700,  654000, -2381, 1861, 534, 240, 585,  852,  873 ),
    0.300: (  -1171,  500,  -294, -511, -2095, 170, 6040, 280,    0, 490, 2460,  40,  750,  587000, -2518, 1865, 544, 215, 585,  831,  848 ),
    0.400: (  -1466,  500,  -186, -592, -2066, 170, 5300, 280,    0, 490, 2587,  40,  850,  503000, -2657, 1874, 541, 217, 583,  785,  756 ),
    0.500: (  -2569,  656,  -304, -536, -2041, 170, 4730, 280,    0, 490, 2544,  40,  883,  457000, -2669, 1883, 550, 214, 590,  735,  631 ),
    0.750: (  -4844,  972,  -578, -406, -2000, 170, 4000, 280,    0, 490, 2133,  77, 1000,  410000, -2401, 1906, 568, 227, 612,  628,  442 ),
    1.000: (  -6406, 1196,  -772, -314, -2000, 170, 4000, 255,    0, 490, 1571, 150, 1000,  400000, -1955, 1929, 568, 255, 623,  534,  290 ),
    1.500: (  -8692, 1513, -1046, -185, -2000, 170, 4000, 161,    0, 490,  406, 253, 1000,  400000, -1025, 1974, 564, 296, 637,  411,  290 ),
    2.000: (  -9701, 1600,  -978, -236, -2000, 170, 4000,  94,    0, 371, -456, 300, 1000,  400000,  -299, 2019, 571, 296, 643,  331,  290 ),
    3.000: ( -10556, 1600,  -638, -491, -2000, 170, 4000,   0,    0, 154, -820, 300, 1000,  400000,     0, 2110, 558, 326, 646,  289,  290 ),
    4.000: ( -11212, 1600,  -316, -770, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2200, 576, 297, 648,  261,  290 ),
    5.000: ( -11684, 1600,   -70, -986, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2291, 601, 359, 700,  200,  290 ),
    7.500: ( -12505, 1600,   -70, -656, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2517, 628, 428, 760,  174,  290 ),
    10.00: ( -13087, 1600,   -70, -422, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2744, 667, 485, 825,  174,  290 ),
    'PGA': (  -1715,  500,  -530, -262, -2118, 170, 5600, 280, -120, 490, 1058,  40,  610,  865000, -1186, 1839, 478, 219, 526, 1000, 1000 ),
    'PGV': (    954,  696,  -309,  -19, -2016, 170, 4000, 245,    0, 358, 1694,  92, 1000,  400000, -1955, 1929, 484, 203, 525,  691,  538 ),
    'PGD': (  -5270, 1600,   -70,    0, -2000, 170, 4000,   0,    0,   0, -820, 300, 1000,  400000,     0, 2744, 667, 485, 825,  174,  290 ),
    }

    params = 0.001 * numpy.array( params[T] )
    n  = 1.18
    cc = 1.88
    c  = params[:13]
    k  = params[13:16]
    sigma_lnY, tau_lnY, sigmaT, rho_sigma, rho_tau = params[16:]
    sigma_lnA_1100  = 0.478
    tau_lnA_1100    = 0.219
    sigma_lnAMP     = 0.3
    sigma_lnY_B     = numpy.sqrt( sigma_lnY**2 - sigma_lnAMP**2 )
    sigma_lnA_1100B = numpy.sqrt( sigma_lnA_1100**2 - sigma_lnAMP**2 )

    f_mag = c[0] + c[1] * M + c[2] * max( 0.0, M - 5.5 ) + c[3] * max( 0.0, M - 6.5 )
    f_dis = ( c[4] + c[5] * M ) * log( sqrt( R_RUP * R_RUP + c[6] * c[6] ) )
    F_RV = numpy.zeros_like( lamb )
    F_NM = numpy.zeros_like( lamb )
    F_RV[   30 < lamb & lamb < 150 ] = 1
    F_NM[ -150 < lamb & lamb < -30 ] = 1
    f_flt = c[7] * F_RV * min( 1, Z_TOR ) + c[8] * F_NM
    i = R_JB > 0 & Z_TOR >= 1
    f_hng = max( R_RUP, sqrt( R_JB * R_JB + 1 ) )
    f_hng = ( f_hng - R_JB ) / f_hng
    f_hng[i] = ( R_RUP(i) - R_JB(i) ) / R_RUP(i)
    f_hng = c(9) * f_hng \
        * min( 1.0, max( 0.0, 2.0 * M - 12.0 ) ) \
        * max( 0.0, 1.0 - 0.05 * Z_TOR ) \
        * min( 1.0, 4.5 - 0.05 * delta )
    f_site = ( c[10] + k[1] * n ) * numpy.log( min( 1100, V_S30 ) / k(1) )
    i = V_S30 < k[0]

    if any( i ):
        sigmaT = sigmaT * numpy.ones_like( V_S30 )
        V_1100 = 1100 * numpy.ones_like( V_S30 )
        A_1100 = cbnga( 'PGA', M, R_RUP, R_JB, Z_TOR, Z_25, V_1100, delta, lamb )
        f_site[i] = c[10] * numpy.log( V_S30[i] / k[0] ) \
            + k[1] * ( numpy.log( A_1100[i] + cc * ( V_S30[i] / k[0] )**n ) - numpy.log( A_1100[i] + cc ) )
        alpha = k[1] * A_1100 * ( 1.0 / ( A_1100 + cc * ( V_S30 / k[0] )**n ) - 1.0 / ( A_1100 + cc ) )
        sigma2 = sigma_lnY**2 \
               + alpha**2 * sigma_lnA_1100B**2 \
               + 2.0 * alpha * rho_sigma * sigma_lnY_B * sigma_lnA_1100B
        tau2 = tau_lnY**2 \
               + alpha**2 * tau_lnA_1100**2 \
               + 2.0 * alpha * rho_tau * tau_lnY * tau_lnA_1100
        sigmaT[i] = numpy.sqrt( sigma2[i] + tau2[i] )

    f_sed = numpy.zeros_like( Z_25 )
    i = Z_25 < 1; f_sed[i] = c[11] * ( Z_25[i] - 1.0 )
    i = Z_25 > 3; f_sed[i] = c[12] * k[2] * numpy.exp( -0.75 ) * ( 1 - numpy.exp( -0.25 * ( Z_25[i] - 3.0 ) ) )
    Y = exp( f_mag + f_dis + f_flt + f_hng + f_site + f_sed )
    if len( sigmaT ) == 1:
        sigmaT = sigmaT * numpy.ones_like( Y )

    return Y, sigmaT

if __name__ == '__main__':
    """
    CBNGA Test - For comparison with OpenSHA Attenuation Relationship Plotter
    """
    import numpy, pylab

    # Choose the intensity measure
    T = 10
    T = 1
    T = 0.1
    T = 0.01
    T = 'PGD'
    T = 'PGV'
    T = 'PGA'

    M = 5.5
    R_RUP = 0.0
    R_JB = R_RUP
    Z_TOR = 0.0
    Z_25 = 1.0
    V_S30 = 760.0
    delta = 90.0
    lamb = 0.0

    M = numpy.arange( 4.0, 8.501, 0.1 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    pylab.figure( 1 )
    pylab.clf()
    pylab.plot( M, Y )
    pylab.xlabel( 'M' )
    pylab.ylabel( T )
    M = 5.5

    V_S30 = numpy.arange( 180.0, 1500.1, 10.0 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    pylab.figure( 2 )
    pylab.clf()
    pylab.plot( V_S30, sigma )
    pylab.xlabel( 'V_{S30}' )
    pylab.ylabel( T )
    V_S30 = 760.0

    Z_25 = numpy.arange( 0.0, 6.01, 0.1 )
    Y, sigma = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
    pylab.figure( 3 )
    pylab.clf()
    pylab.plot( Z_25, Y )
    pylab.xlabel( 'Z_{2.5}' )
    pylab.ylabel( T )
    Z_25 = 1.0

    TT = 0.010, 0.020, 0.030, 0.050, 0.075, 0.100, 0.150, 0.200, 0.250, 0.300, 0.400, 0.500, 0.750, 1.000, 1.500, 2.000, 3.000, 4.000, 5.000, 7.500, 10.00
    Y = []
    sigma = []
    for T in TT:
        tmp = cbnga( T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb )
        Y += [ tmp[0] ]
        sigma += [ tmp[1] ]

    pylab.figure( 4 )
    pylab.clf()
    pylab.loglog( T, Y )
    pylab.xlabel( 'T' )
    pylab.ylabel( 'SA' )

    pylab.figure( 5 )
    pylab.clf()
    pylab.semilogx( T, sigma )
    pylab.xlabel( 'T' )
    pylab.ylabel( '\sigma' )

    pylab.draw()
    pylab.show()

