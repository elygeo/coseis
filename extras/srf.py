#!/usr/bin/env python
"""
Reader for Graves Standard Rupture Format:
http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
"""


def read( filename, headeronly=False, noslip=False ):
    "Read file and return SRF object. Optionally include points with zero slip."
    import sys, numpy
    class obj: pass
    fh = open( filename, 'r' )
    srf = obj()
    srf.version = fh.readline().split()[0]
    k = fh.readline().split()
    if k[0] == 'PLANE':
        srf.nsegments  = int( k[1] )
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 11:
            sys.exit( 'error reading ' + filename )
        srf.nsource2   = int(   k[2] ), int(   k[3]  )
        srf.length     = float( k[4] ), float( k[5]  )
        srf.plane      = float( k[6] ), float( k[7]  )
        srf.topcenter  = float( k[0] ), float( k[1]  ), float( k[8] )
        srf.hypocenter = float( k[9] ), float( k[10] )
        k = fh.readline().split()
    if k[0] != 'POINTS':
        sys.exit( 'error reading ' + filename )
    srf.nsource = int( k[1] )
    if headeronly:
        return srf
    srf.nt   = []
    srf.dt   = []
    srf.t0   = []
    srf.dep  = []
    srf.lon  = []
    srf.lat  = []
    srf.stk  = []
    srf.dip  = []
    srf.rake = []
    srf.area = []
    srf.slip = []
    srf.sv   = []
    for isrc in range( srf.nsource ):
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 15:
            sys.exit( 'error reading ' + filename )
        nt = int( k[10] ), int( k[12] ), int( k[14] )
        if noslip or sum( nt ) > 0:
            srf.nt   += [ nt ]
            srf.dt   += [ float( k[7] ) ]
            srf.t0   += [ float( k[6] ) ]
            srf.dep  += [ float( k[2] ) ]
            srf.lon  += [ float( k[0] ) ]
            srf.lat  += [ float( k[1] ) ]
            srf.stk  += [ float( k[3] ) ]
            srf.dip  += [ float( k[4] ) ]
            srf.rake += [ float( k[8] ) ]
            srf.area += [ float( k[5] ) ]
            srf.slip += [ ( float( k[9] ), float( k[11] ), float( k[13] ) ) ]
            sv = []
            while len( sv ) < sum( nt ):
                sv += fh.readline().split()
            if len( sv ) != sum( nt ):
                sys.exit( 'error reading ' + filename )
            srf.sv += [ float( f ) for f in sv ]
    srf.nsource = len( srf.dt )
    srf.nt   = numpy.array( srf.nt )
    srf.dt   = numpy.array( srf.dt )
    srf.t0   = numpy.array( srf.t0 )
    srf.dep  = numpy.array( srf.dep )
    srf.lon  = numpy.array( srf.lon )
    srf.lat  = numpy.array( srf.lat )
    srf.stk  = numpy.array( srf.stk )
    srf.dip  = numpy.array( srf.dip )
    srf.rake = numpy.array( srf.rake )
    srf.area = numpy.array( srf.area )
    srf.slip = numpy.array( srf.slip )
    srf.sv   = numpy.array( srf.sv )
    return srf

if __name__ == '__main__':
    import sys, pprint, sord
    srf = read( sys.argv[1], True )
    pprint.pprint( sord.util.dictify( srf ) )
    
