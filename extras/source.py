#!/usr/bin/env python
"""
Source utilities
"""
import os, sys, numpy, gzip, coord, sord

def srf_read( filename, path=None, mks=True ):
    """
    Reader for Graves Standard Rupture Format (SRF).

    If path is specified, write binary files. Otherwise, just return header.
    SRF is documented at http://epicenter.usc.edu/cmeportal/docs/srf4.pdf
    """
    fd = filename
    if type( fd ) is not file:
        if fd.split('.')[-1] == 'gz':
            fd = gzip.open( os.path.expanduser( fd ), 'r' )
        else:
            fd = open( os.path.expanduser( fd ), 'r' )

    # Header block
    meta = {}
    meta['version'] = fd.readline().split()[0]
    k = fd.readline().split()
    if k[0] == 'PLANE':
        meta['nsegments'] = int( k[1] )
        k = fd.readline().split() + fd.readline().split()
        if len( k ) != 11:
            sys.exit( 'error reading %s' % filename )
        meta['nsource2']   = int(   k[2] ), int(   k[3]  )
        meta['topcenter']  = float( k[0] ), float( k[1]  ), float( k[8] )
        meta['plane']      = float( k[6] ), float( k[7]  )
        meta['length']     = float( k[4] ), float( k[5]  )
        meta['hypocenter'] = float( k[9] ), float( k[10] )
        if mks:
            meta['length']     = tuple( 1000 * x for x in meta['length'] )
            meta['hypocenter'] = tuple( 1000 * x for x in meta['hypocenter'] )
        k = fd.readline().split()
    if k[0] != 'POINTS':
        sys.exit( 'error reading %s' % filename )
    meta['nsource'] = int( k[1] )
    if not path:
        return meta

    # Data block
    path = os.path.expanduser( path ) + os.sep
    if path not in '.' and not os.path.isdir( path ):
        os.makedirs( path )
    n = meta['nsource']
    lon   = numpy.empty( n )
    lat   = numpy.empty( n )
    dep   = numpy.empty( n )
    stk   = numpy.empty( n )
    dip   = numpy.empty( n )
    rake  = numpy.empty( n )
    area  = numpy.empty( n )
    t0    = numpy.empty( n )
    dt    = numpy.empty( n )
    slip1 = numpy.empty( n )
    slip2 = numpy.empty( n )
    slip3 = numpy.empty( n )
    nt1   = numpy.empty( n, 'i' )
    nt2   = numpy.empty( n, 'i' )
    nt3   = numpy.empty( n, 'i' )
    fd1 = open( path + 'sv1', 'wb' )
    fd2 = open( path + 'sv2', 'wb' )
    fd3 = open( path + 'sv3', 'wb' )
    for i in range( n ):
        k = fd.readline().split() + fd.readline().split()
        if len( k ) != 15:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        lon[i]   = float( k[0] )
        lat[i]   = float( k[1] )
        dep[i]   = float( k[2] )
        stk[i]   = float( k[3] )
        dip[i]   = float( k[4] )
        rake[i]  = float( k[8] )
        area[i]  = float( k[5] )
        t0[i]    = float( k[6] )
        dt[i]    = float( k[7] )
        slip1[i] = float( k[9] )
        slip2[i] = float( k[11] )
        slip3[i] = float( k[13] )
        nt1[i]   = int( k[10] )
        nt2[i]   = int( k[12] )
        nt3[i]   = int( k[14] )
        sv = []
        n = numpy.cumsum([ nt1[i], nt2[i], nt3[i] ])
        while len( sv ) < n[-1]:
            sv += fd.readline().split()
        if len( sv ) != n[-1]:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        sv1 = numpy.array( [ float(f) for f in sv[:n[0]]     ] )
        sv2 = numpy.array( [ float(f) for f in sv[n[0]:n[1]] ] )
        sv3 = numpy.array( [ float(f) for f in sv[n[1]:]     ] )
        if mks:
            sv1 = 0.01 * sv1
            sv2 = 0.01 * sv2
            sv3 = 0.01 * sv3
        numpy.array( sv1, 'f' ).tofile( fd1 )
        numpy.array( sv2, 'f' ).tofile( fd2 )
        numpy.array( sv3, 'f' ).tofile( fd3 )
    fd1.close()
    fd2.close()
    fd3.close()
    if mks:
        dep = 1000.0 * dep
        area = 0.0001 * area
        slip1 = 0.01 * slip1
        slip2 = 0.01 * slip2
        slip3 = 0.01 * slip3
    numpy.array( nt1,   'i' ).tofile( path + 'nt1'   )
    numpy.array( nt2,   'i' ).tofile( path + 'nt2'   )
    numpy.array( nt3,   'i' ).tofile( path + 'nt3'   )
    numpy.array( dt,    'f' ).tofile( path + 'dt'    )
    numpy.array( t0,    'f' ).tofile( path + 't0'    )
    numpy.array( area,  'f' ).tofile( path + 'area'  )
    numpy.array( lon,   'f' ).tofile( path + 'lon'   )
    numpy.array( lat,   'f' ).tofile( path + 'lat'   )
    numpy.array( dep,   'f' ).tofile( path + 'dep'   )
    numpy.array( stk,   'f' ).tofile( path + 'stk'   )
    numpy.array( dip,   'f' ).tofile( path + 'dip'   )
    numpy.array( rake,  'f' ).tofile( path + 'rake'  )
    numpy.array( slip1, 'f' ).tofile( path + 'slip1' )
    numpy.array( slip2, 'f' ).tofile( path + 'slip2' )
    numpy.array( slip3, 'f' ).tofile( path + 'slip3' )

    # Write meta data
    meta['area'] = area.sum()
    meta['potency'] = numpy.sqrt(
        ( area * slip1 ).sum() ** 2 +
        ( area * slip2 ).sum() ** 2 +
        ( area * slip3 ).sum() ** 2 )
    meta['slip'] = meta['potency'] / meta['area']
    meta['dtype'] = numpy.dtype( 'f' ).str
    sord.util.save( path + 'meta.py', meta )
    return meta

def src_write( history, nt, dt, t0, xi, w1, w2=None, path='' ):
    """
    Write SORD input for moment or potency source.
    """
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    numpy.array( history, 'f' ).tofile( path + 'history' )
    numpy.array( nt,      'f' ).tofile( path + 'nt'  )
    numpy.array( dt,      'f' ).tofile( path + 'dt'  )
    numpy.array( t0,      'f' ).tofile( path + 't0'  )
    numpy.array( xi[0],   'f' ).tofile( path + 'xi1' )
    numpy.array( xi[1],   'f' ).tofile( path + 'xi2' )
    numpy.array( xi[2],   'f' ).tofile( path + 'xi3' )
    if not w2:
        numpy.array( w1[0], 'f' ).tofile( path + 'w11' )
        numpy.array( w1[1], 'f' ).tofile( path + 'w12' )
        numpy.array( w1[2], 'f' ).tofile( path + 'w13' )
    else:
        numpy.array( w1[0], 'f' ).tofile( path + 'w11' )
        numpy.array( w1[1], 'f' ).tofile( path + 'w22' )
        numpy.array( w1[2], 'f' ).tofile( path + 'w33' )
        numpy.array( w2[0], 'f' ).tofile( path + 'w23' )
        numpy.array( w2[1], 'f' ).tofile( path + 'w31' )
        numpy.array( w2[2], 'f' ).tofile( path + 'w12' )
    return

def srf2potency( path, projection, dx ):
    """
    Convert SRF to potency tensor source and write SORD input files.
    """

    # Read meta data
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    dtype = meta['dtype']

    # Read data
    nt1  = numpy.fromfile( path + 'nt1',  'i' )
    nt2  = numpy.fromfile( path + 'nt2',  'i' )
    nt3  = numpy.fromfile( path + 'nt3',  'i' )
    dt   = numpy.fromfile( path + 'dt',   dtype )
    t0   = numpy.fromfile( path + 't0',   dtype )
    x    = numpy.fromfile( path + 'lon',  dtype )
    y    = numpy.fromfile( path + 'lat',  dtype )
    z    = numpy.fromfile( path + 'dep',  dtype )
    stk  = numpy.fromfile( path + 'stk',  dtype )
    dip  = numpy.fromfile( path + 'dip',  dtype )
    rake = numpy.fromfile( path + 'rake', dtype )
    area = numpy.fromfile( path + 'area', dtype )

    # Time
    nt = numpy.array( [nt1, nt2, nt3] )
    ii = nt > 0
    nsource = nt[ii].size
    nt[ii].tofile( path + 'src_nt' )
    dt[None].repeat(3,0)[ii].tofile( path + 'src_dt' )
    t0[None].repeat(3,0)[ii].tofile( path + 'src_t0' )

    # Time history
    fd1 = open( path + 'sv1' )
    fd2 = open( path + 'sv2' )
    fd3 = open( path + 'sv3' )
    fd  = open( path + 'src_history', 'wb' )
    for i in range( dt.size ):
        numpy.cumsum( dt[i] * numpy.fromfile(fd1, dtype, nt1[i]) ).tofile( fd )
    for i in range( dt.size ):
        numpy.cumsum( dt[i] * numpy.fromfile(fd2, dtype, nt2[i]) ).tofile( fd )
    for i in range( dt.size ):
        numpy.cumsum( dt[i] * numpy.fromfile(fd3, dtype, nt3[i]) ).tofile( fd )
    fd1.close()
    fd2.close()
    fd3.close()
    fd.close()

    # Coordinates
    rot = coord.rotation( x, y, projection )[1]
    x, y = projection( x, y )
    x = numpy.array( x / dx[0] + 1.0, dtype )
    y = numpy.array( y / dx[1] + 1.0, dtype )
    z = numpy.array( z / dx[2] + 1.0, dtype )
    x[None].repeat(3,0)[ii].tofile( path + 'src_xi1' )
    y[None].repeat(3,0)[ii].tofile( path + 'src_xi2' )
    z[None].repeat(3,0)[ii].tofile( path + 'src_xi3' )

    # Strike, dip, and normal vectors
    R = area * coord.slipvectors( stk + rot, dip, rake )

    # Tensor components
    stk, dip, nrm = numpy.array( coord.source_tensors( R ), dtype )
    w = numpy.zeros_like( stk )
    w[0] = stk[0]; w[1] = dip[0]; w[ii].tofile( path + 'src_w23' )
    w[0] = stk[1]; w[1] = dip[1]; w[ii].tofile( path + 'src_w31' )
    w[0] = stk[2]; w[1] = dip[2]; w[ii].tofile( path + 'src_w12' )
    w = numpy.zeros_like( nrm )
    w[2] = nrm[0]; w[ii].tofile( path + 'src_w11' )
    w[2] = nrm[1]; w[ii].tofile( path + 'src_w22' )
    w[2] = nrm[2]; w[ii].tofile( path + 'src_w33' )

    return nsource

def srf2momrate( path, projection, dx, dt, nt ):
    """
    Convert SRF to moment rate and write Olsen AWM input file.
    """

    # Read meta data
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    dtype = meta['dtype']

    # Read data
    nt1  = numpy.fromfile( path + 'nt1',  'i' )
    nt2  = numpy.fromfile( path + 'nt2',  'i' )
    nt3  = numpy.fromfile( path + 'nt3',  'i' )
    dt0  = numpy.fromfile( path + 'dt',   dtype )
    t0   = numpy.fromfile( path + 't0',   dtype )
    x    = numpy.fromfile( path + 'lon',  dtype )
    y    = numpy.fromfile( path + 'lat',  dtype )
    z    = numpy.fromfile( path + 'dep',  dtype )
    stk  = numpy.fromfile( path + 'stk',  dtype )
    dip  = numpy.fromfile( path + 'dip',  dtype )
    rake = numpy.fromfile( path + 'rake', dtype )
    area = numpy.fromfile( path + 'area', dtype )
    mu   = numpy.fromfile( path + 'mu',   dtype )
    lam  = numpy.fromfile( path + 'lam',  dtype )

    # Coordinates
    rot = coord.rotation( x, y, projection )[1]
    x, y = projection( x, y )
    jj = int( x / dx[0] + 1.5 )
    kk = int( y / dx[1] + 1.5 )
    ll = int( z / dx[2] + 1.5 )

    # Moment tensor components
    R = area * coord.slipvectors( stk + rot, dip, rake )
    stk, dip, nrm = coord.source_tensors( R )
    stk = stk * mu
    dip = dip * mu
    nrm = nrm * lam

    # Time history
    t = dt * numpy.arange( nt )
    fd1 = open( path + 'sv1' )
    fd2 = open( path + 'sv2' )
    fd3 = open( path + 'sv3' )
    fd  = open( path + 'momrate', 'wb' )
    for i in range( dt.size ):
        sv1 = numpy.fromfile( fd1, dtype, nt1[i] )
        sv2 = numpy.fromfile( fd2, dtype, nt2[i] )
        sv3 = numpy.fromfile( fd3, dtype, nt3[i] )
        sv1 = sord.coord.interp( t0[i], dt0[i], sv1, t )
        sv2 = sord.coord.interp( t0[i], dt0[i], sv2, t )
        sv3 = sord.coord.interp( t0[i], dt0[i], sv3, t )
        numpy.array( [jj[i], kk[i], ll[i]], 'i' ).tofile( fd )
        numpy.array( [
            nrm[0,i] * sv3,
            nrm[1,i] * sv3,
            nrm[2,i] * sv3,
            stk[0,i] * sv1, + dip[0,i] * sv2,
            stk[1,i] * sv1, + dip[1,i] * sv2,
            stk[2,i] * sv1, + dip[2,i] * sv2,
        ], 'f' ).tofile( fd )
    fd1.close()
    fd2.close()
    fd3.close()
    fd.close()

    return dt.size

coulomb_header = """\
header line 1
header line 2
#reg1=  0  #reg2=  0  #fixed=  %(nsource)s  sym=  1
 PR1=       0.250     PR2=       0.250   DEPTH=      12.209
  E1=     8.000e+005   E2=     8.000e+005
XSYM=       .000     YSYM=       .000
FRIC=          0.400
S1DR=         19.000 S1DP=         -0.010 S1IN=        100.000 S1GD=          0.000
S2DR=         89.990 S2DP=         89.990 S2IN=         30.000 S2GD=          0.000
S3DR=        109.000 S3DP=         -0.010 S3IN=          0.000 S3GD=          0.000

  #   X-start    Y-start     X-fin      Y-fin   Kode  rt.lat    reverse   dip angle     top      bot
xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
"""

def srf2coulomb( path, projection, dx ):
    """
    Convert SRF to Coulomb input file.
    """

    # Read meta data
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    dtype = meta['dtype']

    # Read data
    nn = meta['nsource2']
    x   = numpy.fromfile( path + 'lon',   dtype )
    y   = numpy.fromfile( path + 'lat',   dtype )
    z   = numpy.fromfile( path + 'dep',   dtype )
    s1  = numpy.fromfile( path + 'slip1', dtype )
    s2  = numpy.fromfile( path + 'slip2', dtype )
    stk = numpy.fromfile( path + 'stk',   dtype )
    dip = numpy.fromfile( path + 'dip',   dtype )

    # Coordinates
    rot = coord.rotation( x, y, projection )[1]
    x, y = 0.001 * projection( x, y )
    z = 0.001 * z
    delta = 0.0005 * meta['dx']
    dx = delta * numpy.sin( numpy.pi / 180.0 * (stk + rot) )
    dy = delta * numpy.cos( numpy.pi / 180.0 * (stk + rot) )
    dz = delta * numpy.sin( numpy.pi / 180.0 * dip )
    x1, x2 = x - dx, x + dx
    y1, y2 = y - dy, y + dy
    z1, z2 = z - dz, z + dz
    c = numpy.array( [x1, y1, x2, y2, s1, s2, dip, z1, z2] ).T

    fd = open( path + 'coulomb.inp', 'w' )
    fd.write( coulomb_header % meta )
    fmt = '  1' + 4*' %10.4f' + ' 100' + 5*' %10.4f' + '    Fault 1'
    numpy.savetxt( fd, c, fmt )

    return

# Command line
if __name__ == '__main__':
    import pprint
    for f in sys.argv[1:]:
        print( f )
        pprint.pprint( srf_read( f, True ) )
 
