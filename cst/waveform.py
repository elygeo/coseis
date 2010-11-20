"""
Tools for working with waveform data
"""
import numpy as np

def csmip_v2( filename ):
    """
    Read strong motion record in CSMIP Volume 2 format.

    California Strong Motion Instrumentation Program:
    http://www.strongmotioncenter.org
    """

    # read file
    ss = open( filename ).readlines()
    j = 0

    # text header
    data = dict(
        date = ss[j+4][49:57] + ss[j+4][59:69],
        lon = float( ss[j+5][29:36] ),
        lat = float( ss[j+5][20:26] ),
    )

    # loop over channels
    while j < len( ss ):

        # integer-value header
        j += 25
        ihdr = []
        n = 5
        while len( ihdr ) < 100:
            j += 1
            ihdr += [ int( ss[j][i:i+n] ) for i in range( 0, len( ss[j] ) - 1, n ) ]
        orient = ihdr[26]

        # real-value header
        rhdr = []
        n = 10
        while len( rhdr ) < 100:
            j += 1
            rhdr += [ float( ss[j][i:i+n] ) for i in range( 0, len( ss[j] ) - 1, n ) ]
        data['dt'] = rhdr[52]

        # data
        n = 10
        data = []
        for w in 'avu':
            v = []
            j += 1
            m = int( ss[j][:8] )
            while len( v ) < m:
                j += 1
                v += [ float( ss[j][i:i+n] ) for i in range( 0, len( ss[j] ) - 1, n ) ]
            k = w + str( orient )
            data[k] = np.array( v )

        # trailer
        j += 1

    return data

