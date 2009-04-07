#!/usr/bin/env python
"""
Source utilities
"""

def f32( a ):
    import numpy
    return numpy.array( a, numpy.float32 )

def write_src( history, nt, dt, t0, xi, w1, w2, path='' ):
    """
    Write SORD input for moment or potency source.
    """
    import os
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    f32( history ).tofile( path + 'history' )
    f32( nt      ).tofile( path + 'nt'  )
    f32( dt      ).tofile( path + 'dt'  )
    f32( t0      ).tofile( path + 't0'  )
    f32( xi[0]   ).tofile( path + 'xi1' )
    f32( xi[1]   ).tofile( path + 'xi2' )
    f32( xi[2]   ).tofile( path + 'xi3' )
    f32( w1[0]   ).tofile( path + 'w11' )
    f32( w1[1]   ).tofile( path + 'w22' )
    f32( w1[2]   ).tofile( path + 'w33' )
    f32( w2[0]   ).tofile( path + 'w23' )
    f32( w2[1]   ).tofile( path + 'w31' )
    f32( w2[2]   ).tofile( path + 'w12' )

def srf_read( filename, headeronly=False, noslip=False, mks=True ):
    """
    Reader for Graves Standard Rupture Format (SRF).
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    Returns separate meta and data objects.
    Optionally include points with zero slip.
    """
    import sys, gzip, numpy
    class obj: pass

    fh = filename
    if type( fh ) is not file:
        if fh.split('.')[-1] == 'gz':
            fh = gzip.open( fh, 'r' )
        else:
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
        if mks:
            meta.length     = 1000.0 * meta.length[0],     1000.0 * meta.length[1]
            meta.hypocenter = 1000.0 * meta.hypocenter[0], 1000.0 * meta.hypocenter[1]
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
    if mks:
        data.dep  = 1000.0 * data.dep
        data.area = 0.0001 * data.area
        data.slip = 0.01   * data.slip
        data.sv   = 0.01   * data.sv
    meta.potency = ( data.area * numpy.sqrt( (data.slip**2).sum(1) ) ).sum()
    return meta, data

def srf2potency( filename, projection, dx, path='' ): 
    """
    Read SRF file and write SORD potency tensor source.
    """
    import os, numpy, coord

    # Read SRF
    meta, data = srf_read( filename )
    dir = os.path.join( path, 'src_' )
    del( meta, data.slip )

    # Time history 
    np = data.nt.shape
    k = 0
    for j in xrange( np[0] ):
        for i in xrange( 3 ):
            nt = data.nt[j,i]
            data.sv[k:k+nt] = data.dt[j] * numpy.cumsum( data.sv[k:k+nt] )
            k = k + nt
    f32( data.sv ).tofile( dir + 'history' )
    del( data.sv )

    # Time
    ii = data.nt > 0
    n = ii.shape
    nsource = data.nt[ii].size
    f32( data.nt )[ii].tofile( dir + 'nt' )
    f32( data.dt ).repeat(3).reshape(n)[ii].tofile( dir + 'dt' )
    f32( data.t0 ).repeat(3).reshape(n)[ii].tofile( dir + 't0' )
    del( data.nt, data.dt, data.t0 )

    # Strike rotation
    mat, rot = coord.rotation( data.lon, data.lat, projection )
    data.stk = data.stk + rot
    del( mat, rot )

    # Strike, dip, and normal vectors
    stk, dip, nrm = coord.slipvectors( data.stk, data.dip, data.rake )
    del( data.stk, data.dip, data.rake )

    # Coordinates
    x, y = projection( data.lon, data.lat )
    x = x / dx[0] + 1.0
    y = y / dx[1] + 1.0
    z = data.dep / dx[2] + 1.0
    f32( x ).repeat(3).reshape(n)[ii].tofile( dir + 'xi1' )
    f32( y ).repeat(3).reshape(n)[ii].tofile( dir + 'xi2' )
    f32( z ).repeat(3).reshape(n)[ii].tofile( dir + 'xi3' )
    del( x, y, z, data.lon, data.lat, data.dep )

    # Normal tensor components
    w = numpy.zeros( np )
    w[:,2] = data.area * nrm[0] * nrm[0]; f32( w )[ii].tofile( dir + 'w11' )
    w[:,2] = data.area * nrm[1] * nrm[1]; f32( w )[ii].tofile( dir + 'w22' )
    w[:,2] = data.area * nrm[2] * nrm[2]; f32( w )[ii].tofile( dir + 'w33' )

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

    return nsource

if __name__ == '__main__':
    import sys, pprint, sord
    for f in sys.argv[1:]:
        print f
        meta = srf_read( f, True )
        pprint.pprint( sord.util.dictify( meta ) )
    
