#!/usr/bin/env python
"""
Source utilities
"""

def srf_read( filename, headeronly=False, mks=True ):
    """
    Reader for Graves Standard Rupture Format (SRF).
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    Returns separate meta and data objects.
    """
    import os, sys, gzip, numpy
    from numpy import array, empty, cumsum, sqrt
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
    n = meta.nsource
    data.lon   = empty( n, 'f' )
    data.lat   = empty( n, 'f' )
    data.dep   = empty( n, 'f' )
    data.stk   = empty( n, 'f' )
    data.dip   = empty( n, 'f' )
    data.rake  = empty( n, 'f' )
    data.area  = empty( n, 'f' )
    data.t0    = empty( n, 'f' )
    data.dt    = empty( n, 'f' )
    data.slip1 = empty( n, 'f' )
    data.slip2 = empty( n, 'f' )
    data.slip3 = empty( n, 'f' )
    data.nt1   = empty( n, 'i' )
    data.nt2   = empty( n, 'i' )
    data.nt3   = empty( n, 'i' )
    data.sv1   = []
    data.sv2   = []
    data.sv3   = []
    for i in xrange( meta.nsource ):
        k = fh.readline().split() + fh.readline().split()
        if len( k ) != 15:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        data.lon[i]   = float( k[0] )
        data.lat[i]   = float( k[1] )
        data.dep[i]   = float( k[2] )
        data.stk[i]   = float( k[3] )
        data.dip[i]   = float( k[4] )
        data.rake[i]  = float( k[8] )
        data.area[i]  = float( k[5] )
        data.t0[i]    = float( k[6] )
        data.dt[i]    = float( k[7] )
        data.slip1[i] = float( k[9] )
        data.slip2[i] = float( k[11] )
        data.slip3[i] = float( k[13] )
        data.nt1[i]   = int( k[10] )
        data.nt2[i]   = int( k[12] )
        data.nt3[i]   = int( k[14] )
        sv = []
        n = cumsum([ data.nt1[i], data.nt2[i], data.nt3[i] ])
        while len( sv ) < n[-1]:
            sv += fh.readline().split()
        if len( sv ) != n[-1]:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        data.sv1 += [ float( f ) for f in sv[:n[0]]     ]
        data.sv2 += [ float( f ) for f in sv[n[0]:n[1]] ]
        data.sv3 += [ float( f ) for f in sv[n[1]:]     ]
    data.sv1 = array( data.sv1 )
    data.sv2 = array( data.sv2 )
    data.sv3 = array( data.sv3 )
    if mks:
        data.dep   = 1000.0 * data.dep
        data.area  = 0.0001 * data.area
        data.slip1 = 0.01   * data.slip1
        data.slip2 = 0.01   * data.slip2
        data.slip3 = 0.01   * data.slip3
        data.sv1   = 0.01   * data.sv1
        data.sv2   = 0.01   * data.sv2
        data.sv3   = 0.01   * data.sv3
    meta.potency = ( data.area * sqrt( data.slip1**2 + data.slip2**2 + data.slip3**2 ) ).sum()
    return meta, data

def srfb_write( meta, data, path='' ):
    """
    Write SRF binary format.
    """
    import os, sord
    from numpy import array
    path = os.path.expanduser( path )
    if not os.path.isdir( path ):
        os.makedirs( path )
    sord.util.save( os.path.join( path, 'meta.py' ), sord.util.dictify( meta ) )
    join = os.path.join
    array( data.lon,   'f' ).tofile( join( path, 'lon' ) )
    array( data.lat,   'f' ).tofile( join( path, 'lat' ) )
    array( data.dep,   'f' ).tofile( join( path, 'dep' ) )
    array( data.stk,   'f' ).tofile( join( path, 'stk' ) )
    array( data.dip,   'f' ).tofile( join( path, 'dip' ) )
    array( data.rake,  'f' ).tofile( join( path, 'rake' ) )
    array( data.area,  'f' ).tofile( join( path, 'area' ) )
    array( data.t0,    'f' ).tofile( join( path, 't0' ) )
    array( data.dt,    'f' ).tofile( join( path, 'dt' ) )
    array( data.slip1, 'f' ).tofile( join( path, 'slip1' ) )
    array( data.slip2, 'f' ).tofile( join( path, 'slip2' ) )
    array( data.slip3, 'f' ).tofile( join( path, 'slip3' ) )
    array( data.sv1,   'f' ).tofile( join( path, 'sv1' ) )
    array( data.sv2,   'f' ).tofile( join( path, 'sv2' ) )
    array( data.sv3,   'f' ).tofile( join( path, 'sv3' ) )
    array( data.nt1,   'i' ).tofile( join( path, 'nt1' ) )
    array( data.nt2,   'i' ).tofile( join( path, 'nt2' ) )
    array( data.nt3,   'i' ).tofile( join( path, 'nt3' ) )
    return

def srfb_read( path='' ):
    """
    Read SRF binary format.
    """
    import os, sord
    from numpy import fromfile
    class obj: pass
    path = os.path.expanduser( path )
    if not os.path.isdir( path ):
        os.makedirs( path )
    meta = sord.util.objectify( sord.util.load( os.path.join( path, 'meta.py' ) ) )
    data = obj()
    join = os.path.join
    data.lon   = fromfile( join( path, 'lon'   ), 'f' )
    data.lat   = fromfile( join( path, 'lat'   ), 'f' )
    data.dep   = fromfile( join( path, 'dep'   ), 'f' )
    data.stk   = fromfile( join( path, 'stk'   ), 'f' )
    data.dip   = fromfile( join( path, 'dip'   ), 'f' )
    data.rake  = fromfile( join( path, 'rake'  ), 'f' )
    data.area  = fromfile( join( path, 'area'  ), 'f' )
    data.t0    = fromfile( join( path, 't0'    ), 'f' )
    data.dt    = fromfile( join( path, 'dt'    ), 'f' )
    data.slip1 = fromfile( join( path, 'slip1' ), 'f' )
    data.slip2 = fromfile( join( path, 'slip2' ), 'f' )
    data.slip3 = fromfile( join( path, 'slip3' ), 'f' )
    data.sv1   = fromfile( join( path, 'sv1'   ), 'f' )
    data.sv2   = fromfile( join( path, 'sv2'   ), 'f' )
    data.sv3   = fromfile( join( path, 'sv3'   ), 'f' )
    data.nt1   = fromfile( join( path, 'nt1'   ), 'i' )
    data.nt2   = fromfile( join( path, 'nt2'   ), 'i' )
    data.nt3   = fromfile( join( path, 'nt3'   ), 'i' )
    return meta, data

def src_write( history, nt, dt, t0, xi, w1, w2, path='' ):
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
    return

def srf2potency( data, projection, dx, path='' ):
    """
    Convert SRF to potency tensor source and write SORD input files.
    """
    import os, coord
    from numpy import array, cumsum, zeros_like
    path = os.path.join( os.path.expanduser( path ), 'src_' )

    # Time history
    i1, i2, i3 = 0, 0, 0
    for i in xrange( data.dt.size ):
        dt, n1, n2, n3 = data.dt[i], data.nt1[i], data.nt2[i], data.nt3[i]
        data.sv1[i1:i1+n1] = dt * cumsum( data.sv1[i1:i1+n1] )
        data.sv2[i2:i2+n2] = dt * cumsum( data.sv2[i2:i2+n2] )
        data.sv3[i3:i3+n3] = dt * cumsum( data.sv3[i3:i3+n3] )
        i1, i2, i3 = i1+n1, i2+n2, i3+n3
    array( [data.sv1, data.sv2, data.sv3], 'f' ).tofile( path + 'history' )
    del( data.sv1, data.sv2, data.sv3 )

    # Time
    nt = array([ data.nt1, data.nt2, data.nt3 ])
    ii = nt > 0
    array( nt, 'f' )[ii].tofile( path + 'nt' )
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
    w = zeros_lile( nrm )
    w[2] = data.area * nrm[0] * nrm[0]; array( w, 'f' )[ii].tofile( path + 'w11' )
    w[2] = data.area * nrm[1] * nrm[1]; array( w, 'f' )[ii].tofile( path + 'w22' )
    w[2] = data.area * nrm[2] * nrm[2]; array( w, 'f' )[ii].tofile( path + 'w33' )

    # Shear tensor components
    w = zeros_like( nrm )
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
 
