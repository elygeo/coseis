#!/usr/bin/env python

def srf_read( filename, headeronly=False, noslip=False ):
    """
    Reader for Graves Standard Rupture Format (SRF).
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    Returns separate meta and data objects.
    Optionally include points with zero slip.
    """
    import sys, numpy
    class obj: pass

    fh = filename
    if type( fh ) is not file:
        fh = open( fh, 'r' )

    # Header block
    meta = obj()
    meta.version = fh.readline().split()[0]
    k = fh.readline().split()
    if k[0] == 'PLANE':
        meta.nsegments  = int( k[1] )
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 11:
            sys.exit( 'error reading %s' % filename )
        meta.nsource2   = int(   k[2] ), int(   k[3]  )
        meta.length     = float( k[4] ), float( k[5]  )
        meta.plane      = float( k[6] ), float( k[7]  )
        meta.topcenter  = float( k[0] ), float( k[1]  ), float( k[8] )
        meta.hypocenter = float( k[9] ), float( k[10] )
        k = fh.readline().split()
    if k[0] != 'POINTS':
        sys.exit( 'error reading %s' % filename )
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
            sys.exit( 'error reading %' % filename )
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
                sys.exit( 'error reading %' % filename )
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

def srf2potency( filename, projection, dx, path='' ): 
    """
    Read SRF file and write SORD potency tensor source
    """
    import os, numpy, coord
    dir = os.path.join( path, 'src_' )
    meta, data = srf_read( filename )
    del( meta, data.slip )

    # Time history 
    k = 0
    for j in xrange( len( data.dt ) ):
        for i in xrange( 3 ):
            nt = data.nt[j,i]
            data.sv[k:k+nt] = data.dt[j] * numpy.cumsum( data.sv[k:k+nt] )
            k = k + nt
    f32( data.sv ).tofile( dir + 'history' )
    del( data.sv )

    # Time
    np = data.nt.shape
    ii = data.nt > 0
    f32( data.nt )[ii].tofile( dir + 'nt' )
    f32( data.dt ).repeat(3)[ii].tofile( dir + 'dt' )
    f32( data.t0 ).repeat(3)[ii].tofile( dir + 't0' )
    del( data.nt, data.dt, data.t0 )

    # Strike rotation
    mat, rot = coord.rotation( data.lon, data.lat, projection )
    data.strike = data.strike + rot
    del( mat, rot )

    # Strike, dip, and normal vectors
    stk, dip, nrm = coord.slipvectors( data.strike, data.dip, data.rake )
    del( data.strike, data.dip, data.rake )

    # Coordinates
    x, y, z = projection( data.lon, data.lat, data.dep )
    x = x / dx[0] + 1.0
    y = y / dx[1] + 1.0
    z = z / dx[2] + 1.0
    f32( x ).repeat(3)[ii].tofile( dir + 'xi1' )
    f32( y ).repeat(3)[ii].tofile( dir + 'xi2' )
    f32( z ).repeat(3)[ii].tofile( dir + 'xi3' )
    del( x, y, z, data.lon, data.lat, data.dep )

    # Normal tensor components
    w = numpy.zeros( np )
    w[:,2] = data.area * nrm[0] * n[0]; f32( w )[ii].tofile( dir + 'w11' )
    w[:,2] = data.area * nrm[1] * n[1]; f32( w )[ii].tofile( dir + 'w22' )
    w[:,2] = data.area * nrm[2] * n[2]; f32( w )[ii].tofile( dir + 'w33' )

    # Shear tensor components
    w = numpy.zeros( np )
    w[:,0] = 0.5 * data.area * ( stk[1] * nrm[2] + nrm[1] * stk[2] )
    w[:,1] = 0.5 * data.area * ( dip[1] * nrm[2] + nrm[1] * dip[2] )
    f32( w )[ii].tofile( dir + 'w23' )
    w[:,0] = 0.5 * data.area * ( stk[2] * nrm[0] + nrm[2] * stk[0] )
    w[:,1] = 0.5 * data.area * ( dip[2] * nrm[0] + nrm[2] * dip[0] )
    f32( w )[ii].tofile( dir + 'w31' )
    w[:,0] = 0.5 * data.area * ( stk[0] * nrm[1] + nrm[0] * stk[1] )
    w[:,1] = 0.5 * data.area * ( dip[0] * nrm[1] + nrm[0] * dip[1] )
    f32( w )[ii].tofile( dir + 'w12' )
    del( w, stk, dip, nrm, data.area )

    return

if __name__ == '__main__':
    import sys, pprint, sord
    meta = read( sys.argv[1], true )
    pprint.pprint( sord.util.dictify( meta ) )
    
