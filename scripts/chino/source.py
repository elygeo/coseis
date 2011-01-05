#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
nt = 2000
dt = 0.02
T = 0.25
sigma = 0.25
t = dt * np.arange( nt )
tau = t - (nt // 2) * dt
tau = np.fft.ifftshift( tau )
s = 0.5 * nt * dt

# Brune
b = t * np.exp( -t / T ) / T ** 2.0
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20 )[0]
ax.text( 0.98, 0.96, 'Brune T=%s' % T, ha='right', va='top', transform=ax.transAxes )

# Gaussian
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma) * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20, shift=True )[0]
ax.text( 0.98, 0.96, 'Gaussian $\sigma=%s$' % sigma, ha='right', va='top', transform=ax.transAxes )

# replace Brune source with Gaussian source
G = ( 1.0 - 2.0 * T / sigma ** 2.0 * tau
    - (T / sigma) ** 2.0 * (1.0 - (tau / sigma) ** 2.0) )
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma) * G
    * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20, shift=True )[0]
ax.text( 0.98, 0.96, 'Replacement', ha='right', va='top', transform=ax.transAxes )

# Hann
b = 0.5 / T * (1.0 + np.cos( np.pi * tau / T ))
i = int( T / dt )
b[i:-i].fill( 0.0 )
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20, shift=True )[0]
ax.text( 0.98, 0.96, 'Hann T=%s' % T, ha='right', va='top', transform=ax.transAxes )

# half cosine
b = np.cos( 0.5 * np.pi * tau / T ) / np.pi
i = int( T / dt )
b[i:-i].fill( 0.0 )
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20, shift=True )[0]
ax.text( 0.98, 0.96, 'Half cosine T=%s' % T, ha='right', va='top', transform=ax.transAxes )

# check with sin wave
b = 3.0 * np.sin( 0.5 * np.pi * t / T )
plt.figure()
ax = cst.signal.spectrum( s * b, dt, tzoom=20 )[0]
ax.text( 0.98, 0.96, 'Sinusoid T=%s' % T, ha='right', va='top', transform=ax.transAxes )

