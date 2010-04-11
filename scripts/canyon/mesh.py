#!/usr/bin/env python
"""
2d Semicircular canyon mesh
"""
import numpy as np

# parameters
r0 = 1.0
n1, n2 = 301, 321
n = (n2 - 1) / 2

# semicircle canyon
f = np.linspace( 0.0, 0.5 * np.pi, n2 )
x = np.empty( [n1, n2] )
y = np.empty( [n1, n2] )
x.fill( np.nan )
y.fill( np.nan )
x[0,:] = np.cos( f ) * r0
y[0,:] = np.sin( f ) * r0

# flank
for i in range( 1, n1 ):
    #r = 1.0 + (0.25 * np.pi * (n1 - 1 - i) + i) / n / (n1 - 1) # 1 to 1 at canyon
    r = 1.0 + (0.5 * np.pi * (n1 - 1 - i) + i) / n / (n1 - 1) # 2 to 1 at canyon
    x[i,0] = x[i-1,0] * r

# outer edge
L = x[-1,0]
x[-1,:] = L
y[-1,:] = L
dx = L / n
y[-1,:n] = np.arange( n ) * dx
x[-1,-n:] = np.arange( n )[::-1] * dx

# blend
dx = x[-1,0] - x[0,0]
for i in range( 1, n1-1 ):
    w = (x[-1,0] - x[i,0]) / dx
    x[i,:] = w * x[0,:] + (1.0 - w) * x[-1,:]
    y[i,:] = w * y[0,:] + (1.0 - w) * y[-1,:]

# singel precision
x = np.array( x, 'f' )
y = np.array( y, 'f' )

# continue if not imported
if __name__ == '__main__':

    # print mesh properties
    vp = 2.0
    dy = y[0,1] - y[0,0]
    dt = dy * 1.5 / vp / np.sqrt( 3.0 )
    print 'L = ', L
    print 'nn = ', (n1, n2)
    print 'nt > ', L / vp / dt
    print 'dt < ', dt
    print 'dx00 = ', (x[1,0]  - x[0,0],  y[0,1]  - y[0,0])
    print 'dx01 = ', (x[0,-2] - x[0,-1], y[1,-1] - y[0,-1])
    print 'dx10 = ', (x[-1,0] - x[-2,0], y[-1,1] - y[-1,0])
    print 'dx11 = ', (x[-1,-2] - x[-1,-1], y[-1,-1] - y[-2,-1])
    print 'L / n =', L / n

    # plot
    import matplotlib.pyplot as plt
    fig = plt.gcf()
    fig.clf()
    ax = fig.add_subplot( 111 )
    d = 8
    x, y = x[::d,::d], y[::d,::d]
    ax.plot( x, y, 'k-' )
    ax.plot( -x, y, 'k-' )
    ax.plot( x.T, y.T, 'k-' )
    ax.plot( -x.T, y.T, 'k-' )
    ax.axis( 'scaled' )
    ax.axis( [-2, 2, 2, -0.2] )
    fig.canvas.draw()
    fig.show()

