#!/usr/bin/env python
import os
import cst.kostrov
import numpy as np
import matplotlib.pyplot as plt

b = 0.9  # Vrup / Vs ratio
a = b / np.sqrt(3.0)  # Poisson solid

# plot like Dahlen (1974), Fig 3
fig = plt.figure(None, (5, 5), 100, 'w')
fig.clf()
ax = fig.gca()
ax.axis('image')
ax.axis([0, 1, 0, 1])
ax.set_xlabel(r'$\mu/\beta$')
ax.set_ylabel(r'$C(\mu/\beta,\mu/\beta,\nu)$')
ax.set_xticks([0, 0.5, 1])
ax.set_yticks([0, 0.5, 1])
ax.set_xticklabels(['0', 0.5, '1'])
ax.set_yticklabels(['0', 0.5, '1'])

# range of Vrup/Vs values, avoid singularities at the endpoints
b = np.linspace(0, 1, 100)
b[0] = 1e-160
b[-1] -= 1e-16
a = b / np.sqrt(3.0)

# plot curve
ax.plot(b, cst.kostrov.cee(a, b), 'k-')

# limiting cases for nu = 0.25, Dahlen (1974), eqn. (45)
if 1:
    C = b * 24.0 / 7.0 / np.pi
    ax.plot(b, C, 'k--')
    b = 0.9,  1.0
    C = 0.81, 8.0 / 9.0
    ax.plot(b, C, 'k.', clip_on=False)
    ax.set_xticks([0, 0.5, 0.9, 1])
    ax.set_yticks([0, 0.5, 0.81, 8.0 / 9.0, 1])
    ax.set_xticklabels(['0', 0.5, 0.9, '1'])
    ax.set_yticklabels(['0', 0.5, 0.81, '8/9', '1'])

    # scan overlay
    f = '../figures/Kostrov-Cee-Dahlen1974.png'
    if os.path.exists(f):
        img = plt.imread(f)
        img[:, :, 0] = 1.0
        extent = -0.0045, 1.002, -0.007, 1.005
        ax.imshow(img, aspect='equal', extent=extent)
        b = 0, 0, 1, 1
        C = 0, 1, 0, 1
        ax.plot(b, C, '+r')

fig.savefig('Kostrov-Cee.pdf')
