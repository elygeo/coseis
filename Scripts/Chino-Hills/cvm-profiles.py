#!/usr/bin/env python
"""
CVM profiles
"""
import os
import numpy as np
import pyproj
import cst

# data directory
path = os.path.join('run', 'data') + os.sep

# mesh
y, x = np.loadtxt(path + 'station-list.txt', usecols=(1, 2)).T
z_ = np.linspace(0.0, 500.0, 501)
z, x = np.meshgrid(z_, x)
z, y = np.meshgrid(z_, y)

# cvms
r, p, s = cst.cvms.extract(x, y, z, ['rho', 'vp', 'vs'])
np.save(path + 'CVMS-Rho.npy', r.astype('f'))
np.save(path + 'CVMS-Vp.npy',  p.astype('f'))
np.save(path + 'CVMS-Vs.npy',  s.astype('f'))

# project to cvm-h coordinates
proj = pyproj.Proj(**cst.cvmh.projection)
x, y = proj(x, y)

# cvmh
r, p, s = cst.cvmh.extract(x, y, z, ['rho', 'vp', 'vs'], False, vs30=None, no_data_value='nan')
np.save(path + 'CVMH-Rho.npy', r.astype('f'))
np.save(path + 'CVMH-Vp.npy',  p.astype('f'))
np.save(path + 'CVMH-Vs.npy',  s.astype('f'))

# cvmg
r, p, s = cst.cvmh.extract(x, y, z, ['rho', 'vp', 'vs'], False)
np.save(path + 'CVMG-Rho.npy', r.astype('f'))
np.save(path + 'CVMG-Vp.npy',  p.astype('f'))
np.save(path + 'CVMG-Vs.npy',  s.astype('f'))

