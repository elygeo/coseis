#!/usr/bin/env python
"""
Reader for Graves Standard Rupture Format (SRF):
http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
"""

def srf_read( filename, headeronly=False, noslip=False ):
    """
    Read SRF file and return meta and data objects.
    Optionally include points with zero slip.
    """
    import sys, numpy
    class obj: pass
    fh = open( filename, 'r' )

    # Header block
    meta = obj()
    meta.version = fh.readline().split()[0]
    k = fh.readline().split()
    if k[0] == 'PLANE':
        meta.nsegments  = int( k[1] )
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 11:
            sys.exit( 'error reading ' + filename )
        meta.nsource2   = int(   k[2] ), int(   k[3]  )
        meta.length     = float( k[4] ), float( k[5]  )
        meta.plane      = float( k[6] ), float( k[7]  )
        meta.topcenter  = float( k[0] ), float( k[1]  ), float( k[8] )
        meta.hypocenter = float( k[9] ), float( k[10] )
        k = fh.readline().split()
    if k[0] != 'POINTS':
        sys.exit( 'error reading ' + filename )
    meta.nsource = int( k[1] )
    if headeronly:
        return meta

    # Data block
    data = obj()
    data.nt   = []
    data.dt   = []
    data.t0   = []
    data.dep  = []
    data.lon  = []
    data.lat  = []
    data.stk  = []
    data.dip  = []
    data.rake = []
    data.area = []
    data.slip = []
    data.sv   = []
    for isrc in range( meta.nsource ):
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 15:
            sys.exit( 'error reading ' + filename )
        nt = int( k[10] ), int( k[12] ), int( k[14] )
        if noslip or sum( nt ) > 0:
            data.nt   += [ nt ]
            data.dt   += [ float( k[7] ) ]
            data.t0   += [ float( k[6] ) ]
            data.dep  += [ float( k[2] ) ]
            data.lon  += [ float( k[0] ) ]
            data.lat  += [ float( k[1] ) ]
            data.stk  += [ float( k[3] ) ]
            data.dip  += [ float( k[4] ) ]
            data.rake += [ float( k[8] ) ]
            data.area += [ float( k[5] ) ]
            data.slip += [ ( float( k[9] ), float( k[11] ), float( k[13] ) ) ]
            sv = []
            while len( sv ) < sum( nt ):
                sv += fh.readline().split()
            if len( sv ) != sum( nt ):
                sys.exit( 'error reading ' + filename )
            data.sv += [ float( f ) for f in sv ]
    meta.nsource = len( data.dt )
    data.nt   = numpy.array( data.nt )
    data.dt   = numpy.array( data.dt )
    data.t0   = numpy.array( data.t0 )
    data.dep  = numpy.array( data.dep )
    data.lon  = numpy.array( data.lon )
    data.lat  = numpy.array( data.lat )
    data.stk  = numpy.array( data.stk )
    data.dip  = numpy.array( data.dip )
    data.rake = numpy.array( data.rake )
    data.area = numpy.array( data.area )
    data.slip = numpy.array( data.slip )
    data.sv   = numpy.array( data.sv )
    return meta, data

def f32( a ):
    import numpy
    return numpy.array( a, numpy.float32 )

def srf2potency( data, projection, path='' ): 
    """
    Convert SRF representation to potency tensors
    """
    import os, numpy, coord
    dir = os.path.join( path, 'src_' )

    # Time
    ii = data.nt > 0
    f32( data.nt )[ii].tofile( dir + 'nt' )
    f32( data.t0 ).repeat(3)[ii].tofile( dir + 't0' )
    f32( data.dt ).repeat(3)[ii].tofile( dir + 'dt' )

    # Time history
    su = numpy.zeros_like( data.sv )
    j = 0
    for i in xrange( len( data.dt ) ):
        nt = data.nt[i]
        su[j:j+nt] = data.dt[i] * numpy.cumsum( su[j:j+nt] )
        j = j + nt
    f32( su ).tofile( dir + 'history' )

    # Coordinates
    x, y, z = projection( data.lon, data.lat, data.dep ):
    x = x / dx[0] + 1.0
    y = y / dx[1] + 1.0
    z = z / dx[2] + 1.0
    f32( x ).repeat(3)[ii].tofile( dir + 'xi1' )
    f32( y ).repeat(3)[ii].tofile( dir + 'xi2' )
    f32( z ).repeat(3)[ii].tofile( dir + 'xi3' )
    del( x, y, z )

    # Strike dip, and rake components
    s, d, n = coord.slipvectors( data.strike, data.dip, data.rake )

    # Normal tensor components
    w = numpy.zeros_like( data.nt )
    w[:,2] = data.area * n[0] * n[0]; f32( w )[ii].tofile( dir + 'w11' )
    w[:,2] = data.area * n[1] * n[1]; f32( w )[ii].tofile( dir + 'w22' )
    w[:,2] = data.area * n[2] * n[2]; f32( w )[ii].tofile( dir + 'w33' )

    # Shear tensor components
    w = numpy.zeros_like( data.nt )
    w[:,0] = 0.5 * data.area * ( s[1] * n[2] + n[1] * s[2] )
    w[:,1] = 0.5 * data.area * ( d[1] * n[2] + n[1] * d[2] )
    f32( w )[ii].tofile( dir + 'w23' )
    w[:,0] = 0.5 * data.area * ( s[2] * n[0] + n[2] * s[0] )
    w[:,1] = 0.5 * data.area * ( d[2] * n[0] + d[2] * d[0] )
    f32( w )[ii].tofile( dir + 'w31' )
    w[:,0] = 0.5 * data.area * ( s[0] * n[1] + n[0] * s[1] )
    w[:,1] = 0.5 * data.area * ( d[0] * n[1] + n[0] * d[1] )
    f32( w )[ii].tofile( dir + 'w12' )

    return

if __name__ == '__main__':
    import sys, getopt, pprint, sord
    #opts, args = getopt.getopt( sys.argv[1:], 'aso' )
    meta = read( sys.argv[1], true )
    pprint.pprint( sord.util.dictify( meta ) )
    
