"""
Source utilities
"""
import os, sys, urllib, gzip
import numpy as np
from . import util, coord

def scsn_mts( eventid ):
    """
    Retrieve Southern California Seismic Network Moment Tensor Solutions.
    """
    url = 'http://www.data.scec.org/MomentTensor/solutions/web_%s/ci%s_MT.html' % (eventid, eventid)
    url = 'http://www.data.scec.org/MomentTensor/solutions/%s/' % eventid
    url = 'http://www.data.scec.org/MomentTensor/showMT.php?evid=%s' % eventid
    text = urllib.urlopen( url )
    event = {}
    clvd = [[[], [], []], [[], [], []]]
    dc   = [[[], [], []], [[], [], []]]
    for line in text.readlines():
        line = line.strip()
        if ':' in line and line[0] != ' ':
            f = line.split( ':', 1 )
            k = f[0].strip()
            if k in ('Origin Time', 'Stations', 'Quality Factor'):
                event[k] = f[1].strip()
            elif k in ('Event ID', 'Number of Stations used'):
                event[k] = int( f[1] )
            elif k in ('Magnitude', 'Depth (km)', 'Latitude', 'Longitude', 'Moment Magnitude'):
                event[k] = float( f[1] )
            elif k == 'Best Fitting Double Couple and CLVD Solution':
                tensor = clvd
            elif k == 'Best Fitting Double Couple Solution':
                tensor = dc
        elif line:
            f = line.split()
            if f[0] == 'Mxx':
                tensor[0][0] = float( f[1] )
            elif f[0] == 'Myy':
                tensor[0][1] = float( f[1] )
            elif f[0] == 'Mzz':
                tensor[0][2] = float( f[1] )
            elif f[0] == 'Myz':
                tensor[1][0] = float( f[1] )
            elif f[0] == 'Mxz':
                tensor[1][1] = float( f[1] )
            elif f[0] == 'Mxy':
                tensor[1][2] = float( f[1] )
    event['double-couple-clvd'] = np.array( clvd )
    event['double-couple'] = np.array( dc )
    return event

def magarea( A ):
    """
    Various earthquake magnitude area relations.
    """
    A = np.array( A, copy=False, ndmin=1 )
    i = A > 537.0
    Mw = 3.98 + np.log10( A )
    Mw[i] = 3.08 + 4.0 / 3.0 * np.log10( A )
    Mw = dict(
        Hanks2008 = Mw,
        EllsworthB2003 = 4.2 + np.log10( A ),
        Somerville2006 = 3.87 + 1.05 * np.log10( A ),
        Wells1994 = 3.98 + 1.02 * np.log10( A ),
    )
    return Mw

def src_write( history, nt, dt, t0, xi, w1, w2=None, path='' ):
    """
    Write SORD input for moment or potency source.
    """
    path = os.path.join( os.path.expanduser( path ), 'src_' )
    np.asarray( history, 'f' ).tofile( path + 'history.bin' )
    np.asarray( nt,      'i' ).tofile( path + 'nt.bin'  )
    np.asarray( dt,      'f' ).tofile( path + 'dt.bin'  )
    np.asarray( t0,      'f' ).tofile( path + 't0.bin'  )
    np.asarray( xi[0],   'f' ).tofile( path + 'xi1.bin' )
    np.asarray( xi[1],   'f' ).tofile( path + 'xi2.bin' )
    np.asarray( xi[2],   'f' ).tofile( path + 'xi3.bin' )
    if not w2:
        np.asarray( w1[0], 'f' ).tofile( path + 'w11.bin' )
        np.asarray( w1[1], 'f' ).tofile( path + 'w12.bin' )
        np.asarray( w1[2], 'f' ).tofile( path + 'w13.bin' )
    else:
        np.asarray( w1[0], 'f' ).tofile( path + 'w11.bin' )
        np.asarray( w1[1], 'f' ).tofile( path + 'w22.bin' )
        np.asarray( w1[2], 'f' ).tofile( path + 'w33.bin' )
        np.asarray( w2[0], 'f' ).tofile( path + 'w23.bin' )
        np.asarray( w2[1], 'f' ).tofile( path + 'w31.bin' )
        np.asarray( w2[2], 'f' ).tofile( path + 'w12.bin' )
    return

def cybershake( isrc, irup, islip, ihypo, path='srf', name=None ):
    """
    Download and prep CyberShake source files.

    Must have account on intensity.usc.edu with auto SSH authentication.

    Parameters
    ----------
        isrc : source ID
        irup : rupture ID
        islip : slip variation ID
        ihypo : hypocenter ID
        path : destination directory
        name : optional name for the rupture
    """

    # if already present just return metadata
    if path:
        path += os.sep
    if os.path.exists( path ):
        meta = util.load( path + 'meta.py' )
        return meta
    cwd = os.getcwd()
    print isrc, irup, islip, ihypo, name

    # get reports
    d = os.path.dirname( os.path.normpath( path ) )
    get = 'scp intensity.usc.edu:/home/scec-00/cybershk/reports/'
    for f in 'erf35_source_rups.txt', 'erf35_sources.txt':
        ff = os.path.join( d, f )
        if not os.path.exists( ff ):
            os.system( get + f + ' ' + ff )
    segments = dict( np.loadtxt( ff, 'i,S64', delimiter='\t', skiprows=1 ) )

    # get source files
    os.mkdir( path )
    os.chdir( path )
    get = 'scp intensity.usc.edu:/home/rcf-104/CyberShake2007/ruptures/RuptureVariations_35_V3_2/%d/%d/' % (isrc, irup)
    get = 'scp intensity.usc.edu:/home/rcf-104/CyberShake2007/ruptures/RuptureVariations_35_V2_3/%d/%d/' % (isrc, irup)
    mesh = '%d_%d.txt' % (isrc, irup)
    head = '%d_%d.txt.variation.output' % (isrc, irup)
    srf  = '%d_%d.txt.variation-s%04d-h%04d' % (isrc, irup, islip, ihypo)
    os.system( get + head + ' head' )
    os.system( get + mesh + ' mesh' )
    os.system( get + srf  + ' srf'  )

    # extract SRF file
    srf_read( 'srf', '.' )

    # update metadata
    meta = util.load( 'meta.py' )
    shape = meta.plane[0]['shape']
    v = open( 'head' ).readline().split()
    meta.nslip = int( v[6] )
    meta.nhypo = int( v[8] )
    fd = open( 'mesh', 'r' )
    meta.probability = float( fd.readline().split()[-1] )
    meta.magnitude   = float( fd.readline().split()[-1] )
    fd.close()
    meta.segment = segments[isrc].replace( ';', ' ' )
    meta.event = name
    meta.isrc = isrc
    meta.irup = irup
    meta.islip = islip
    meta.ihypo = ihypo
    if not name:
        meta.name = meta.segment
    util.save( 'meta.py', meta, expand=['plane'], header='# source parameters\n' )

    # extract trace
    x = np.fromfile( 'lon', 'f' ).reshape( shape[::-1] ).T
    y = np.fromfile( 'lat', 'f' ).reshape( shape[::-1] ).T
    np.savetxt( 'trace.txt', np.array( [x[:,0], y[:,0]] ).T, '%f' )

    # clean up
    os.system( 'gzip srf' )
    os.remove( 'mesh' )
    os.remove( 'head' )
    os.chdir( cwd )
    return meta

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
            fd = open( os.path.expanduser( fd ) )

    # Header block
    meta = {}
    meta['version'] = fd.readline().split()[0]
    k = fd.readline().split()
    if k[0] == 'PLANE':
        plane = []
        for i in range( int( k[1] ) ):
            k = fd.readline().split() + fd.readline().split()
            if len( k ) != 11:
                sys.exit( 'error reading %s' % filename )
            seg = {
                'topcenter':  ( float( k[0] ), float( k[1]  ), float( k[8] ) ),
                'shape':      ( int(   k[2] ), int(   k[3]  ) ),
                'length':     ( float( k[4] ), float( k[5]  ) ),
                'strike':       float( k[6] ),
                'dip':          float( k[7] ),
                'hypocenter': ( float( k[9] ), float( k[10] ) ),
            }
            if mks:
                x, y = seg['length']
                seg['length'] = 1000.0 * x, 1000.0 * y
                x, y = seg['hypocenter']
                seg['hypocenter'] = 1000.0 * x, 1000.0 * y
            x, y = seg['length']
            j, k = seg['shape']
            seg['delta'] = x / j, y / k
            plane += [seg]
        meta['plane'] = plane
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
    lon   = np.empty( n )
    lat   = np.empty( n )
    dep   = np.empty( n )
    stk   = np.empty( n )
    dip   = np.empty( n )
    rake  = np.empty( n )
    area  = np.empty( n )
    t0    = np.empty( n )
    dt    = np.empty( n )
    slip1 = np.empty( n )
    slip2 = np.empty( n )
    slip3 = np.empty( n )
    nt1   = np.empty( n, 'i' )
    nt2   = np.empty( n, 'i' )
    nt3   = np.empty( n, 'i' )
    fd1 = open( path + 'sv1.bin', 'wb' )
    fd2 = open( path + 'sv2.bin', 'wb' )
    fd3 = open( path + 'sv3.bin', 'wb' )
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
        n = np.cumsum([ nt1[i], nt2[i], nt3[i] ])
        while len( sv ) < n[-1]:
            sv += fd.readline().split()
        if len( sv ) != n[-1]:
            sys.exit( 'error reading %s %s' % ( filename, i ) )
        sv1 = np.array( [ float(f) for f in sv[:n[0]]     ] )
        sv2 = np.array( [ float(f) for f in sv[n[0]:n[1]] ] )
        sv3 = np.array( [ float(f) for f in sv[n[1]:]     ] )
        if mks:
            sv1 = 0.01 * sv1
            sv2 = 0.01 * sv2
            sv3 = 0.01 * sv3
        np.array( sv1, 'f' ).tofile( fd1 )
        np.array( sv2, 'f' ).tofile( fd2 )
        np.array( sv3, 'f' ).tofile( fd3 )
    fd1.close()
    fd2.close()
    fd3.close()
    if mks:
        dep = 1000.0 * dep
        area = 0.0001 * area
        slip1 = 0.01 * slip1
        slip2 = 0.01 * slip2
        slip3 = 0.01 * slip3
    np.array( nt1,   'i' ).tofile( path + 'nt1.bin'   )
    np.array( nt2,   'i' ).tofile( path + 'nt2.bin'   )
    np.array( nt3,   'i' ).tofile( path + 'nt3.bin'   )
    np.array( dt,    'f' ).tofile( path + 'dt.bin'    )
    np.array( t0,    'f' ).tofile( path + 't0.bin'    )
    np.array( area,  'f' ).tofile( path + 'area.bin'  )
    np.array( lon,   'f' ).tofile( path + 'lon.bin'   )
    np.array( lat,   'f' ).tofile( path + 'lat.bin'   )
    np.array( dep,   'f' ).tofile( path + 'dep.bin'   )
    np.array( stk,   'f' ).tofile( path + 'stk.bin'   )
    np.array( dip,   'f' ).tofile( path + 'dip.bin'   )
    np.array( rake,  'f' ).tofile( path + 'rake.bin'  )
    np.array( slip1, 'f' ).tofile( path + 'slip1.bin' )
    np.array( slip2, 'f' ).tofile( path + 'slip2.bin' )
    np.array( slip3, 'f' ).tofile( path + 'slip3.bin' )

    # Write meta data
    i = np.argmin( t0 )
    meta['hypocenter'] = lon.flat[i], lat.flat[i], dep.flat[i]
    meta['nsource_nonzero'] = (nt1>0).sum() + (nt2>0).sum() + (nt3>0).sum()
    meta['area'] = area.sum()
    meta['potency'] = np.sqrt(
        ( area * slip1 ).sum() ** 2 +
        ( area * slip2 ).sum() ** 2 +
        ( area * slip3 ).sum() ** 2 )
    meta['slip'] = meta['potency'] / meta['area']
    meta['dtype_i'] = np.dtype( 'i' ).str
    meta['dtype_f'] = np.dtype( 'f' ).str
    util.save( path + 'meta.py', meta, expand=['plane'] )
    return meta

def srf2potency( src, path, delta=(1,1,1), proj=None ):
    """
    Convert SRF to potency tensor source and write SORD input files.

    Parameters
    ----------
        src : path to SRF source directory converted first with srf_read
        path : path to destination directory for potency tensors
        delta : grid step size (dx, dy, dz)
        proj : function to project lon/lat to logical model coordinates
    """

    # Read meta data
    src  = os.path.expanduser( src ) + os.sep
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( src + 'meta.py' ) in meta
    dtype_f = meta['dtype_f']
    dtype_i = meta['dtype_i']

    # Read data
    nt1  = np.fromfile( src + 'nt1',  dtype_i )
    nt2  = np.fromfile( src + 'nt2',  dtype_i )
    nt3  = np.fromfile( src + 'nt3',  dtype_i )
    dt   = np.fromfile( src + 'dt',   dtype_f )
    t0   = np.fromfile( src + 't0',   dtype_f )
    x    = np.fromfile( src + 'lon',  dtype_f )
    y    = np.fromfile( src + 'lat',  dtype_f )
    z    = np.fromfile( src + 'dep',  dtype_f )
    stk  = np.fromfile( src + 'stk',  dtype_f )
    dip  = np.fromfile( src + 'dip',  dtype_f )
    rake = np.fromfile( src + 'rake', dtype_f )
    area = np.fromfile( src + 'area', dtype_f )

    # create destination directory
    if path not in '.' and not os.path.isdir( path ):
        os.makedirs( path )

    # Time
    nt = np.array( [nt1, nt2, nt3] )
    ii = nt > 0
    nsource = nt[ii].size
    nt[ii].tofile( path + 'src_nt.bin' )
    dt[None].repeat(3,0)[ii].tofile( path + 'src_dt.bin' )
    t0[None].repeat(3,0)[ii].tofile( path + 'src_t0.bin' )

    # Time history
    fd1 = open( src + 'sv1.bin' )
    fd2 = open( src + 'sv2.bin' )
    fd3 = open( src + 'sv3.bin' )
    fd  = open( path + 'src_history.bin', 'wb' )
    for i in range( dt.size ):
        np.cumsum( dt[i] * np.fromfile(fd1, dtype_f, nt1[i]) ).tofile( fd )
    for i in range( dt.size ):
        np.cumsum( dt[i] * np.fromfile(fd2, dtype_f, nt2[i]) ).tofile( fd )
    for i in range( dt.size ):
        np.cumsum( dt[i] * np.fromfile(fd3, dtype_f, nt3[i]) ).tofile( fd )
    fd1.close()
    fd2.close()
    fd3.close()
    fd.close()

    # Coordinates
    rot = coord.rotation( x, y, proj )[1]
    if proj is not None:
        x, y = proj( x, y )
    x = np.asarray( 1.0 + x / delta[0], dtype_f )
    y = np.asarray( 1.0 + y / delta[1], dtype_f )
    z = np.asarray( 1.0 + z / delta[2], dtype_f )
    x[None].repeat(3,0)[ii].tofile( path + 'src_xi1.bin' )
    y[None].repeat(3,0)[ii].tofile( path + 'src_xi2.bin' )
    z[None].repeat(3,0)[ii].tofile( path + 'src_xi3.bin' )

    # Strike, dip, and normal vectors
    R = coord.slipvectors( stk + rot, dip, rake )

    # Tensor components
    stk, dip, nrm = np.asarray( area * coord.source_tensors( R ), dtype_f )
    w = np.zeros_like( stk )
    w[0] = stk[0]; w[1] = dip[0]; w[ii].tofile( path + 'src_w23.bin' )
    w[0] = stk[1]; w[1] = dip[1]; w[ii].tofile( path + 'src_w31.bin' )
    w[0] = stk[2]; w[1] = dip[2]; w[ii].tofile( path + 'src_w12.bin' )
    w = np.zeros_like( nrm )
    w[2] = nrm[0]; w[ii].tofile( path + 'src_w11.bin' )
    w[2] = nrm[1]; w[ii].tofile( path + 'src_w22.bin' )
    w[2] = nrm[2]; w[ii].tofile( path + 'src_w33.bin' )

    return nsource

def srf2momrate( path, proj, delta, dt, nt, embed_indices=False ):
    """
    Convert SRF to moment rate and write Olsen AWM input file.
    """

    # Read meta data
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    dtype_f = meta['dtype_f']
    dtype_i = meta['dtype_i']

    # Read data
    nt1  = np.fromfile( path + 'nt1.bin',  dtype_i )
    nt2  = np.fromfile( path + 'nt2.bin',  dtype_i )
    nt3  = np.fromfile( path + 'nt3.bin',  dtype_i )
    dt0  = np.fromfile( path + 'dt.bin',   dtype_f )
    t0   = np.fromfile( path + 't0.bin',   dtype_f )
    x    = np.fromfile( path + 'lon.bin',  dtype_f )
    y    = np.fromfile( path + 'lat.bin',  dtype_f )
    z    = np.fromfile( path + 'dep.bin',  dtype_f )
    stk  = np.fromfile( path + 'stk.bin',  dtype_f )
    dip  = np.fromfile( path + 'dip.bin',  dtype_f )
    rake = np.fromfile( path + 'rake.bin', dtype_f )
    area = np.fromfile( path + 'area.bin', dtype_f )
    mu   = np.fromfile( path + 'mu.bin',   dtype_f )
    lam  = np.fromfile( path + 'lam.bin',  dtype_f )

    # Coordinates
    rot = coord.rotation( x, y, proj )[1]
    x, y = proj( x, y )
    jj = int( x / delta[0] + 1.5 )
    kk = int( y / delta[1] + 1.5 )
    ll = int( z / delta[2] + 1.5 )

    # Moment tensor components
    R = coord.slipvectors( stk + rot, dip, rake )
    stk, dip, nrm = area * coord.source_tensors( R )
    stk = stk * mu
    dip = dip * mu
    nrm = nrm * lam

    # Time history
    t = dt * np.arange( nt )
    fd1 = open( path + 'sv1.bin' )
    fd2 = open( path + 'sv2.bin' )
    fd3 = open( path + 'sv3.bin' )
    fd  = open( path + 'momrate.bin', 'wb' )
    for i in range( dt.size ):
        sv1 = np.fromfile( fd1, dtype_f, nt1[i] )
        sv2 = np.fromfile( fd2, dtype_f, nt2[i] )
        sv3 = np.fromfile( fd3, dtype_f, nt3[i] )
        sv1 = coord.interp( t0[i], dt0[i], sv1, t )
        sv2 = coord.interp( t0[i], dt0[i], sv2, t )
        sv3 = coord.interp( t0[i], dt0[i], sv3, t )
        if embed_indices:
            np.array( [jj[i], kk[i], ll[i]], dtype_i ).tofile( fd )
        np.array( [
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

def dsample( f, d ):
    """
    Downsample 2d array.
    """
    if not d:
        return f
    n = f.shape
    n = n[0] / d, n[1] / d
    g = np.zeros( n )
    for j in range( d ):
        for k in range( d ):
            g = g + f[j,::d,k::d]
    g = g / (d * d)
    return g

def srf2coulomb( path, proj, dest=None, scut=0 ):
    """
    Convert SRF to Coulomb input file.
    """

    if dest is None:
        dest = os.path.join( path, 'coulomb-' )

    # Meta data
    path = os.path.expanduser( path ) + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    dtype_f = meta['dtype_f']

    # Read files
    x    = np.fromfile( path + 'lon.bin',   dtype_f )
    y    = np.fromfile( path + 'lat.bin',   dtype_f )
    z    = np.fromfile( path + 'dep.bin',   dtype_f )
    stk  = np.fromfile( path + 'stk.bin',   dtype_f )
    dip  = np.fromfile( path + 'dip.bin',   dtype_f )
    rake = np.fromfile( path + 'rake.bin',  dtype_f )
    s1   = np.fromfile( path + 'slip1.bin', dtype_f )
    s2   = np.fromfile( path + 'slip2.bin', dtype_f )

    # Slip components
    s = np.sin( np.pi / 180.0 * rake )
    c = np.cos( np.pi / 180.0 * rake )
    r1 = -c * s1 + s * s2
    r2 =  s * s1 + c * s2

    # Coordinates
    rot = coord.rotation( x, y, proj )[1]
    x, y = proj( x, y )
    x *= 0.001
    y *= 0.001
    z *= 0.001
    delta = 0.0005 * meta['plane'][0]['delta'][0]
    dx = delta * np.sin( np.pi / 180.0 * (stk + rot) )
    dy = delta * np.cos( np.pi / 180.0 * (stk + rot) )
    dz = delta * np.sin( np.pi / 180.0 * dip )
    x1, x2 = x - dx, x + dx
    y1, y2 = y - dy, y + dy
    z1, z2 = z - dz, z + dz

    # Source file
    i = (s1**2 + s2**2) > (np.sign( scut ) * scut**2)
    c = np.array( [x1[i], y1[i], x2[i], y2[i], r1[i], r2[i], dip[i], z1[i], z2[i]] ).T
    fd = open( dest + 'source.inp', 'w' )
    fd.write( coulomb_header % meta )
    np.savetxt( fd, c, coulomb_fmt )
    fd.write( coulomb_footer )
    fd.close()

    # Receiver file
    s1.fill( 0.0 )
    c = np.array( [x1, y1, x2, y2, s1, s1, dip, z1, z2] ).T
    fd = open( dest + 'receiver.inp', 'w' )
    fd.write( coulomb_header % meta )
    np.savetxt( fd, c, coulomb_fmt )
    fd.write( coulomb_footer )
    fd.close()

    return

coulomb_fmt = '  1' + 4*' %10.4f' + ' 100' + 5*' %10.4f' + '    Fault 1'

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

coulomb_footer = """
   Grid Parameters
  1  ----------------------------  Start-x =     -100.0
  2  ----------------------------  Start-y =        0.0
  3  --------------------------   Finish-x =      500.0
  4  --------------------------   Finish-y =      400.0
  5  ------------------------  x-increment =        5.0
  6  ------------------------  y-increment =        5.0
     Size Parameters
  1  --------------------------  Plot size =        2.0
  2  --------------  Shade/Color increment =        1.0
  3  ------  Exaggeration for disp.& dist. =    10000.0

     Cross section default
  1  ----------------------------  Start-x =     -126.4
  2  ----------------------------  Start-y =     -124.6
  3  --------------------------   Finish-x =       40.0
  4  --------------------------   Finish-y =       40.0
  5  ------------------  Distant-increment =        1.0
  6  ----------------------------  Z-depth =       30.0
  7  ------------------------  Z-increment =        1.0
     Map info
  1  ---------------------------- min. lon =     -128.0
  2  ---------------------------- max. lon =     -123.0
  3  ---------------------------- zero lon =     -125.0
  4  ---------------------------- min. lat =       39.5
  5  ---------------------------- max. lat =       42.5
  6  ---------------------------- zero lat =       40.0
"""

