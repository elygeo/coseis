#!/usr/bin/env python3
import os
import json
import cst
import numpy as np

os.chdir(cst.repo + 'TPV12-2D')

# parameters
meta = json.load(open('meta.json'))
meta['dx'] = meta['delta'][0]
meta['dt'] = meta['delta'][3]
meta['nt'] = meta['shape'][3]
t = np.arange(meta['nt']) * meta['dt']

# formats
fmt1 = '%20.12f' + 7 * ' %14.6f'
fmt2 = '%20.12f' + 6 * ' %14.6f'

# headers
header = """\
# problem=TPV12-2D
# author=Geoffrey Ely
# date={rundate}
# code=SORD
# element_size={dx}
# time_step={dt}
# num_time_steps={nt}
# location={sta}
"""
header1 = """\
# Column #1 = Time (s)
# Column #2 = horizontal slip (m)
# Column #3 = horizontal slip rate (m/s)
# Column #4 = horizonatl shear stress (MPa)
# Column #5 = vertical slip (m)
# Column #6 = vertical slip rate (m/s)
# Column #7 = vertical shear stress (MPa)
# Column #8 = normal stress (MPa)
t h-slip h-slip-rate h-shear-stress v-slip v-slip-rate v-shear-stress n-stress
"""
header2 = """\
# Column #1 = Time (s)
# Column #2 = horizontal displacement (m)
# Column #3 = horizontal velocity (m/s)
# Column #4 = vertical displacement (m)
# Column #5 = vertical velocity (m/s)
# Column #6 = normal displacement (m)
# Column #7 = normal velocity (m/s)
t h-disp h-vel v-disp v-vel n-disp n-vel
"""

# fault stations
for sta in meta['deltas']:
    if sta.startswith('fault') and sta.endswith('su1.npy'):
        sta = sta[:-8]
        meta['sta'] = sta
        f = sta + '-%s.npy'
        su1 = np.load(f % 'su1')
        y = np.load(f % 'su2')
        z = np.load(f % 'su3')
        suv = np.sqrt(y * y + z * z)
        sv1 = np.load(f % 'sv1')
        y = np.load(f % 'sv2')
        z = np.load(f % 'sv3')
        svv = np.sqrt(y * y + z * z)
        ts1 = np.load(f % 'ts1') * 1e-6
        y = np.load(f % 'ts2')
        z = np.load(f % 'ts3')
        tsv = np.sqrt(y * y + z * z) * 1e-6
        tnm = np.load(f % 'tnm') * 1e-6
        c = np.array([t, su1, sv1, ts1, suv, svv, tsv, tnm]).T
        f = sta + '.asc'
        with open(f, 'w') as fh:
            fh.write(header % meta)
            fh.write(header1)
            np.savetxt(fh, c, fmt1)

# body stations
for sta in meta['deltas']:
    if sta.startswith('body') and sta.endswith('u1.npy'):
        sta = sta[:-7]
        meta['sta'] = sta
        f = sta + '-%s.npy'
        u1 = np.load(f % 'u1')
        u2 = np.load(f % 'u2')
        u3 = np.load(f % 'u3')
        v1 = np.load(f % 'v1')
        v2 = np.load(f % 'v2')
        v3 = np.load(f % 'v3')
        c = np.array([t, u1, v1, u2, v2, u3, v3]).T
        f = sta + '.asc'
        with open(f, 'w') as fh:
            fh.write(header % meta)
            fh.write(header2)
            np.savetxt(fh, c, fmt2)
