#!/usr/bin/env python
"""
Source utilities
"""

def write_src( history, nt, dt, t0, xi, w1, w2, path='' ):
    """
    Write SORD input for moment or potency source.
    """
    import os
    from numpy import array
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    array( history, 'f' ).tofile( path + 'history' )
    array( nt, 'f'      ).tofile( path + 'nt'  )
    array( dt, 'f'      ).tofile( path + 'dt'  )
    array( t0, 'f'      ).tofile( path + 't0'  )
    array( xi[0], 'f'   ).tofile( path + 'xi1' )
    array( xi[1], 'f'   ).tofile( path + 'xi2' )
    array( xi[2], 'f'   ).tofile( path + 'xi3' )
    array( w1[0], 'f'   ).tofile( path + 'w11' )
    array( w1[1], 'f'   ).tofile( path + 'w22' )
    array( w1[2], 'f'   ).tofile( path + 'w33' )
    array( w2[0], 'f'   ).tofile( path + 'w23' )
    array( w2[1], 'f'   ).tofile( path + 'w31' )
    array( w2[2], 'f'   ).tofile( path + 'w12' )

def srf_read( filename, headeronly=False, mks=True ):
    """
    Reader for Graves Standard Rupture Format (SRF).
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    Returns separate meta and data objects.
    """
    import os, sys, gzip, numpy
    class obj: pass

    fh = filename
    if type( fh ) is not file:
        if fh.split('.')[-1] == 'gz':
            fh = gzip.open( os.path.expanduser( fh ), 'r' )
        else:
            fh = open( os.path.expanduser( fh ), 'r' )

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
    data.nt1   = []
    data.nt2   = []
    data.nt3   = []
    data.dt    = []
    data.t0    = []
    data.dep   = []
    data.lon   = []
    data.lat   = []
    data.stk   = []
    data.dip   = []
    data.rake  = []
    data.area  = []
    data.slip1 = []
    data.slip2 = []
    data.slip3 = []
    data.sv1   = []
    data.sv2   = []
    data.sv3   = []
    for isrc in range( meta.nsource ):
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 15:
            sys.exit( 'error reading %' % filename )
        data.nt1   += [ int( k[10] ) ]
        data.nt2   += [ int( k[12] ) ]
        data.nt3   += [ int( k[14] ) ]
        data.dt    += [ float( k[7] ) ]
        data.t0    += [ float( k[6] ) ]
        data.dep   += [ float( k[2] ) ]
        data.lon   += [ float( k[0] ) ]
        data.lat   += [ float( k[1] ) ]
        data.stk   += [ float( k[3] ) ]
        data.dip   += [ float( k[4] ) ]
        data.rake  += [ float( k[8] ) ]
        data.area  += [ float( k[5] ) ]
        data.slip1 += [ float( k[9] ) ]
        data.slip2 += [ float( k[11] ) ]
        data.slip3 += [ float( k[13] ) ]
        sv = []
        n = numpy.cumsum([ data.nt1[-1], data.nt2[-1], data.nt3[-1] ])
        while len( sv ) < n[2]:
            sv += fh.readline().split()
        if len( sv ) != n[2]:
            sys.exit( 'error reading %' % filename )
        data.sv1 += [ float( f ) for f in sv[:n[0]]     ]
        data.sv2 += [ float( f ) for f in sv[n[0]:n[1]] ]
        data.sv3 += [ float( f ) for f in sv[n[1]:]     ]
    meta.nsource = len( data.dt )
    data.nt1   = numpy.array( data.nt1   )
    data.nt2   = numpy.array( data.nt2   )
    data.nt3   = numpy.array( data.nt3   )
    data.dt    = numpy.array( data.dt    )
    data.t0    = numpy.array( data.t0    )
    data.dep   = numpy.array( data.dep   )
    data.lon   = numpy.array( data.lon   )
    data.lat   = numpy.array( data.lat   )
    data.stk   = numpy.array( data.stk   )
    data.dip   = numpy.array( data.dip   )
    data.rake  = numpy.array( data.rake  )
    data.area  = numpy.array( data.area  )
    data.slip1 = numpy.array( data.slip1 )
    data.slip2 = numpy.array( data.slip2 )
    data.slip3 = numpy.array( data.slip3 )
    data.sv1   = numpy.array( data.sv1   )
    data.sv2   = numpy.array( data.sv2   )
    data.sv3   = numpy.array( data.sv3   )
    if mks:
        data.dep   = 1000.0 * data.dep
        data.area  = 0.0001 * data.area
        data.slip1 = 0.01   * data.slip1
        data.slip2 = 0.01   * data.slip2
        data.slip3 = 0.01   * data.slip3
        data.sv1   = 0.01   * data.sv1
        data.sv2   = 0.01   * data.sv2
        data.sv3   = 0.01   * data.sv3
    meta.potency = ( data.area * numpy.sqrt( data.slip1**2 + data.slip2**2 + data.slip3**2 ) ).sum()
    return meta, data

def srf2potency( filename, projection, dx, path='' ):
    """
    Read SRF file and write SORD potency tensor source.
    """
    import os, numpy, coord
    array = numpy.array

    # Read SRF
    meta, data = srf_read( filename )
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    del( meta, data.slip1, data.slip2, data.slip3 )

    # Time history
    i1, i2, i3 = 0, 0, 0
    for i in xrange( data.dt.size ):
        dt, n1, n2, n3 = data.dt[i], data.nt1[i], data.nt2[i], data.nt3[i]
        data.sv1[i1:i1+n1] = dt * numpy.cumsum( data.sv1[i1:i1+n1] )
        data.sv2[i2:i2+n2] = dt * numpy.cumsum( data.sv2[i2:i2+n2] )
        data.sv3[i3:i3+n3] = dt * numpy.cumsum( data.sv3[i3:i3+n3] )
        i1, i2, i3 = i1+n1, i2+n2, i3+n3
    array( [data.sv1, data.sv2, data.sv3], 'f' ).tofile( path + 'history' )
    del( data.sv1, data.sv2, data.sv3 )

    # Time
    nt = array([ data.nt1, data.nt2, data.nt3 ])
    ii = nt > 0
    nt[ii].tofile( path + 'nt' )
    array( data.dt, 'f' )[None].repeat(3,0)[ii].tofile( path + 'dt' )
    array( data.t0, 'f' )[None].repeat(3,0)[ii].tofile( path + 't0' )
    nsource = nt[ii].size
    del( nt, data.nt1, data.nt2, data.nt3, data.dt, data.t0 )

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
    array( x, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi1' )
    array( y, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi2' )
    array( z, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi3' )
    del( x, y, z, data.lon, data.lat, data.dep )

    # Normal tensor components
    w = numpy.zeros_lile( nrm )
    w[2] = data.area * nrm[0] * nrm[0]; array( w, 'f' )[ii].tofile( path + 'w11' )
    w[2] = data.area * nrm[1] * nrm[1]; array( w, 'f' )[ii].tofile( path + 'w22' )
    w[2] = data.area * nrm[2] * nrm[2]; array( w, 'f' )[ii].tofile( path + 'w33' )

    # Shear tensor components
    w = numpy.zeros_lile( nrm )
    w[0] = 0.5 * data.area * ( stk[1] * nrm[2] + nrm[1] * stk[2] )
    w[1] = 0.5 * data.area * ( dip[1] * nrm[2] + nrm[1] * dip[2] )
    array( w, 'f' )[ii].tofile( path + 'w23' )
    w[0] = 0.5 * data.area * ( stk[2] * nrm[0] + nrm[2] * stk[0] )
    w[1] = 0.5 * data.area * ( dip[2] * nrm[0] + nrm[2] * dip[0] )
    array( w, 'f' )[ii].tofile( path + 'w31' )
    w[0] = 0.5 * data.area * ( stk[0] * nrm[1] + nrm[0] * stk[1] )
    w[1] = 0.5 * data.area * ( dip[0] * nrm[1] + nrm[0] * dip[1] )
    array( w, 'f' )[ii].tofile( path + 'w12' )
    del( w, stk, dip, nrm, data.area )

    return nsource

if __name__ == '__main__':
    import sys, pprint, sord
    for f in sys.argv[1:]:
        print f
        meta = srf_read( f, True )
        pprint.pprint( sord.util.dictify( meta ) )
 
