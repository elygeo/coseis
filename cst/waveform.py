"""
Waveform data tools.
"""
import numpy as np


def csmip_vol2(filename, max_year=2050):
    """
    Read strong motion record in CSMIP Volume 2 format.

    California Strong Motion Instrumentation Program:
    http://www.strongmotioncenter.org
    """

    # read file
    ss = open(filename).readlines()
    j = 0

    # text header
    t = ss[j+4][59:69]
    m = int(ss[j+4][49:51])
    d = int(ss[j+4][52:54])
    y = int(ss[j+4][55:57]) + 2000
    if y > max_year:
        y -= 100
    time = '%04d/%02d/%02dT%s' % (y, m, d, t)
    lon = ss[j+5][29:36]
    lat = ss[j+5][20:26]
    data = {'time': time, 'lon': lon, 'lat': lat}

    # loop over channels
    while j < len(ss):

        # integer-value header
        j += 25
        ihdr = []
        n = 5
        while len(ihdr) < 100:
            ihdr += [int(ss[j][i:i+n]) for i in range(0, len(ss[j]) - 2, n)]
            j += 1
        orient = ihdr[26]

        # real-value header
        rhdr = []
        n = 10
        while len(rhdr) < 100:
            rhdr += [float(ss[j][i:i+n]) for i in range(0, len(ss[j]) - 2, n)]
            j += 1
        data['dt'] = rhdr[52]

        # data
        n = 10
        for w in 'avd':
            m = int(ss[j][:6])
            v = []
            j += 1
            while len(v) < m:
                v += [float(ss[j][i:i+n]) for i in range(0, len(ss[j]) - 2, n)]
                j += 1
            k = '%s%03d' % (w, orient)
            data[k] = np.array(v)

        # trailer
        j += 1

    return data
