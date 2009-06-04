#!/usr/bin/env python
"""
Source utilities
"""
import os, sys, numpy, gzip, coord, sord

def srf_read( filename, headeronly=False, mks=True ):
    """
    Reader for Graves Standard Rupture Format (SRF).
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    Returns separate meta and data objects.
    """
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
    data.lon   = numpy.empty( n, 'f' )
    data.lat   = numpy.empty( n, 'f' )
    data.dep   = numpy.empty( n, 'f' )
    data.stk   = numpy.empty( n, 'f' )
    data.dip   = numpy.empty( n, 'f' )
    data.rake  = numpy.empty( n, 'f' )
    data.area  = numpy.empty( n, 'f' )
    data.t0    = numpy.empty( n, 'f' )
    data.dt    = numpy.empty( n, 'f' )
    data.slip1 = numpy.empty( n, 'f' )
    data.slip2 = numpy.empty( n, 'f' )
    data.slip3 = numpy.empty( n, 'f' )
    data.nt1   = numpy.empty( n, 'i' )
    data.nt2   = numpy.empty( n, 'i' )
    data.nt3   = numpy.empty( n, 'i' )
    data.sv1   = []
    data.sv2   = []
    data.sv3   = []
    for i in range( meta.nsource ):
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
        n = numpy.cumsum([ data.nt1[i], data.nt2[i], data.nt3[i] ])
        while len( sv ) < n[-1]:
            sv += fh.readline().split()
        if len( sv ) != n[-1]:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        data.sv1 += [ float( f ) for f in sv[:n[0]]     ]
        data.sv2 += [ float( f ) for f in sv[n[0]:n[1]] ]
        data.sv3 += [ float( f ) for f in sv[n[1]:]     ]
    data.sv1 = numpy.array( data.sv1 )
    data.sv2 = numpy.array( data.sv2 )
    data.sv3 = numpy.array( data.sv3 )
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

def srfb_write( meta, data, path='' ):
    """
    Write SRF binary format.
    """
    path = os.path.expanduser( path )
    if not os.path.isdir( path ):
        os.makedirs( path )
    meta.dtype = numpy.dtype( 'f' ).str
    sord.util.save( os.path.join( path, 'meta.py' ), sord.util.dictify( meta ) )
    numpy.array( data.lon,   'f' ).tofile( os.path.join( path, 'lon' ) )
    numpy.array( data.lat,   'f' ).tofile( os.path.join( path, 'lat' ) )
    numpy.array( data.dep,   'f' ).tofile( os.path.join( path, 'dep' ) )
    numpy.array( data.stk,   'f' ).tofile( os.path.join( path, 'stk' ) )
    numpy.array( data.dip,   'f' ).tofile( os.path.join( path, 'dip' ) )
    numpy.array( data.rake,  'f' ).tofile( os.path.join( path, 'rake' ) )
    numpy.array( data.area,  'f' ).tofile( os.path.join( path, 'area' ) )
    numpy.array( data.t0,    'f' ).tofile( os.path.join( path, 't0' ) )
    numpy.array( data.dt,    'f' ).tofile( os.path.join( path, 'dt' ) )
    numpy.array( data.slip1, 'f' ).tofile( os.path.join( path, 'slip1' ) )
    numpy.array( data.slip2, 'f' ).tofile( os.path.join( path, 'slip2' ) )
    numpy.array( data.slip3, 'f' ).tofile( os.path.join( path, 'slip3' ) )
    numpy.array( data.sv1,   'f' ).tofile( os.path.join( path, 'sv1' ) )
    numpy.array( data.sv2,   'f' ).tofile( os.path.join( path, 'sv2' ) )
    numpy.array( data.sv3,   'f' ).tofile( os.path.join( path, 'sv3' ) )
    numpy.array( data.nt1,   'i' ).tofile( os.path.join( path, 'nt1' ) )
    numpy.array( data.nt2,   'i' ).tofile( os.path.join( path, 'nt2' ) )
    numpy.array( data.nt3,   'i' ).tofile( os.path.join( path, 'nt3' ) )
    return

def srfb_read( path='' ):
    """
    Read SRF binary format.
    """
    class obj: pass
    path = os.path.expanduser( path )
    if not os.path.isdir( path ):
        os.makedirs( path )
    meta = sord.util.objectify( sord.util.load( os.path.join( path, 'meta.py' ) ) )
    data = obj()
    data.lon   = numpy.fromfile( os.path.join( path, 'lon'   ), 'f' )
    data.lat   = numpy.fromfile( os.path.join( path, 'lat'   ), 'f' )
    data.dep   = numpy.fromfile( os.path.join( path, 'dep'   ), 'f' )
    data.stk   = numpy.fromfile( os.path.join( path, 'stk'   ), 'f' )
    data.dip   = numpy.fromfile( os.path.join( path, 'dip'   ), 'f' )
    data.rake  = numpy.fromfile( os.path.join( path, 'rake'  ), 'f' )
    data.area  = numpy.fromfile( os.path.join( path, 'area'  ), 'f' )
    data.t0    = numpy.fromfile( os.path.join( path, 't0'    ), 'f' )
    data.dt    = numpy.fromfile( os.path.join( path, 'dt'    ), 'f' )
    data.slip1 = numpy.fromfile( os.path.join( path, 'slip1' ), 'f' )
    data.slip2 = numpy.fromfile( os.path.join( path, 'slip2' ), 'f' )
    data.slip3 = numpy.fromfile( os.path.join( path, 'slip3' ), 'f' )
    data.sv1   = numpy.fromfile( os.path.join( path, 'sv1'   ), 'f' )
    data.sv2   = numpy.fromfile( os.path.join( path, 'sv2'   ), 'f' )
    data.sv3   = numpy.fromfile( os.path.join( path, 'sv3'   ), 'f' )
    data.nt1   = numpy.fromfile( os.path.join( path, 'nt1'   ), 'i' )
    data.nt2   = numpy.fromfile( os.path.join( path, 'nt2'   ), 'i' )
    data.nt3   = numpy.fromfile( os.path.join( path, 'nt3'   ), 'i' )
    return meta, data

def src_write( history, nt, dt, t0, xi, w1, w2=None, path='' ):
    """
    Write SORD input for moment or potency source.
    """
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    numpy.array( history, 'f' ).tofile( path + 'history' )
    numpy.array( nt, 'f'      ).tofile( path + 'nt'  )
    numpy.array( dt, 'f'      ).tofile( path + 'dt'  )
    numpy.array( t0, 'f'      ).tofile( path + 't0'  )
    numpy.array( xi[0], 'f'   ).tofile( path + 'xi1' )
    numpy.array( xi[1], 'f'   ).tofile( path + 'xi2' )
    numpy.array( xi[2], 'f'   ).tofile( path + 'xi3' )
    if not w2:
        numpy.array( w1[0], 'f'   ).tofile( path + 'w11' )
        numpy.array( w1[1], 'f'   ).tofile( path + 'w12' )
        numpy.array( w1[2], 'f'   ).tofile( path + 'w13' )
    else:
        numpy.array( w1[0], 'f'   ).tofile( path + 'w11' )
        numpy.array( w1[1], 'f'   ).tofile( path + 'w22' )
        numpy.array( w1[2], 'f'   ).tofile( path + 'w33' )
        numpy.array( w2[0], 'f'   ).tofile( path + 'w23' )
        numpy.array( w2[1], 'f'   ).tofile( path + 'w31' )
        numpy.array( w2[2], 'f'   ).tofile( path + 'w12' )
    return

def srf2potency( data, projection, dx, path='' ):
    """
    Convert SRF to potency tensor source and write SORD input files.
    """
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    del( data.slip1, data.slip2, data.slip3 )

    # Time history
    i1, i2, i3 = 0, 0, 0
    for i in range( data.dt.size ):
        dt, n1, n2, n3 = data.dt[i], data.nt1[i], data.nt2[i], data.nt3[i]
        data.sv1[i1:i1+n1] = dt * numpy.cumsum( data.sv1[i1:i1+n1] )
        data.sv2[i2:i2+n2] = dt * numpy.cumsum( data.sv2[i2:i2+n2] )
        data.sv3[i3:i3+n3] = dt * numpy.cumsum( data.sv3[i3:i3+n3] )
        i1, i2, i3 = i1+n1, i2+n2, i3+n3
    numpy.array( [data.sv1, data.sv2, data.sv3], 'f' ).tofile( path + 'history' )
    del( data.sv1, data.sv2, data.sv3 )

    # Time
    nt = numpy.array([ data.nt1, data.nt2, data.nt3 ])
    ii = nt > 0
    numpy.array( nt, 'f' )[ii].tofile( path + 'nt' )
    numpy.array( data.dt, 'f' )[None].repeat(3,0)[ii].tofile( path + 'dt' )
    numpy.array( data.t0, 'f' )[None].repeat(3,0)[ii].tofile( path + 't0' )
    nsource = nt[ii].size
    del( nt, data.nt1, data.nt2, data.nt3, data.dt, data.t0 )

    # Coordinates
    x, y = projection( data.lon, data.lat )
    x = x / dx[0] + 1.0
    y = y / dx[1] + 1.0
    z = data.dep / dx[2] + 1.0
    numpy.array( x, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi1' )
    numpy.array( y, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi2' )
    numpy.array( z, 'f' )[None].repeat(3,0)[ii].tofile( path + 'xi3' )
    del( x, y, z, data.lon, data.lat, data.dep )

    # Strike rotation
    mat, rot = coord.rotation( data.lon, data.lat, projection )
    data.stk = data.stk + rot
    del( mat, rot )

    # Strike, dip, and normal vectors
    R = data.area * coord.slipvectors( data.stk, data.dip, data.rake )
    del( data.area, data.stk, data.dip, data.rake )

    # Tensor components
    stk, dip, nrm = coord.source_tensors( R )
    w = numpy.zeros_like( stk )
    w[0] = stk[0]; w[1] = dip[0]; numpy.array( w, 'f' )[ii].tofile( path + 'w23' )
    w[0] = stk[1]; w[1] = dip[1]; numpy.array( w, 'f' )[ii].tofile( path + 'w31' )
    w[0] = stk[2]; w[1] = dip[2]; numpy.array( w, 'f' )[ii].tofile( path + 'w12' )
    w = numpy.zeros_lile( nrm )
    w[2] = nrm[0]; numpy.array( w, 'f' )[ii].tofile( path + 'w11' )
    w[2] = nrm[1]; numpy.array( w, 'f' )[ii].tofile( path + 'w22' )
    w[2] = nrm[2]; numpy.array( w, 'f' )[ii].tofile( path + 'w33' )

    return nsource

def srf2momrate( data, projection, dx, dt, nt, path='momrate' ):
    """
    Convert SRF to moment rate and write Olsen AWM input file.
    """

    # Strike rotation
    mat, rot = coord.rotation( data.lon, data.lat, projection )
    data.stk = data.stk + rot
    del( mat, rot )

    # Coordinates
    x, y = projection( data.lon, data.lat )
    jj = int( x / dx[0] + 1.5 )
    kk = int( y / dx[1] + 1.5 )
    ll = int( data.dep / dx[2] + 1.5 )
    del( x, y, data.lon, data.lat, data.dep )

    # Strike, dip, and normal vectors
    R = data.area * coord.slipvectors( data.stk, data.dip, data.rake )
    del( data.area, data.stk, data.dip, data.rake )

    # Moment tensor components
    stk, dip, nrm = coord.source_tensors( R )
    stk = stk * data.mu
    dip = dip * data.mu
    nrm = nrm * data.lam
    del( R, data.lam, data.mu )

    # Time history
    t = dt * numpy.arange( nt )
    fd = open( os.path.expanduser( path ), 'wb' )
    i1, i2, i3 = 0, 0, 0
    for i in range( data.dt.size ):
        dt0, t0 = data.dt[i], data.t0[i]
        n1, n2, n3 = data.nt1[i], data.nt2[i], data.nt3[i]
        sv1 = sord.coord.interp( t0, dt0, data.sv1[i1:i1+n1], t )
        sv2 = sord.coord.interp( t0, dt0, data.sv2[i2:i2+n2], t )
        sv3 = sord.coord.interp( t0, dt0, data.sv3[i3:i3+n3], t )
        i1, i2, i3 = i1+n1, i2+n2, i3+n3
        numpy.array([ jj[i], kk[i], ll[i] ], 'i' ).tofile( fd )
        numpy.array([
            nrm[0,i] * sv3,
            nrm[1,i] * sv3,
            nrm[2,i] * sv3,
            stk[0,i] * sv1, + dip[0,i] * sv2,
            stk[1,i] * sv1, + dip[1,i] * sv2,
            stk[2,i] * sv1, + dip[2,i] * sv2,
        ], 'f' ).tofile( fd )
    fd.close()

    return

if __name__ == '__main__':
    import pprint
    for f in sys.argv[1:]:
        print( f )
        meta = srf_read( f, True )
        pprint.pprint( sord.util.dictify( meta ) )
 
