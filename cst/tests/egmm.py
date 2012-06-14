#!/usr/bin/env ipython -i --gui=wx

def test():
    """
    Test CBNGA for comparison with OpenSHA Attenuation Relationship Plotter
    """
    import numpy as np
    import matplotlib.pyplot as plt
    import cst

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
    Y, sigma = cst.egmm.cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)
    plt.figure(1)
    plt.clf()
    plt.plot(M, Y)
    plt.xlabel('M')
    plt.ylabel(T)
    M = 5.5,

    V_S30 = np.arange(180.0, 1500.1, 10.0)
    Y, sigma = cst.egmm.cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)
    plt.figure(2)
    plt.clf()
    plt.plot(V_S30, sigma)
    plt.xlabel('$V_{S30}$')
    plt.ylabel(T)
    V_S30 = 760.0,

    Z_25 = np.arange(0.0, 6.01, 0.1)
    Y, sigma = cst.egmm.cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)
    plt.figure(3)
    plt.clf()
    plt.plot(Z_25, Y)
    plt.xlabel('$Z_{2.5}$')
    plt.ylabel(T)
    Z_25 = 1.0,

    TT = (0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3,
           0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0)
    Y = []
    sigma = []
    for T in TT:
        tmp = cst.egmm.cbnga(T, M, R_RUP, R_JB, Z_TOR, Z_25, V_S30, delta, lamb)
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

# command line
if __name__ == '__main__':
    test()

