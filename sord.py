#!/usr/bin/env python

import os, sys, getopt, time, glob
import shutil, imp, subprocess
from numpy import index_exp as _

# Main SORD setup routine
def sord( argv ):

    # Save start time
    starttime = time.asctime()
    print "SORD setup"

    # Command line options
    setup = True
    run = False
    mode = None
    machine = None
    optimize = 'O'
    opt, infiles = getopt.getopt( argv[1:], 'niqspgGm:fd' )
    for o, v in opt:
        if   o == '-n': setup = False; run = False
        elif o == '-i': run = 'i'
        elif o == '-q': run = 'q'
        elif o == '-s': mode = 's'
        elif o == '-p': mode = 'p'
        elif o == '-g': optimize = 'g'
        elif o == '-G': optimize = 'g'; run = 'g'
        elif o == '-m': machine = v
        elif o == '-f':
            f = 'tmp' + os.sep + '*'
            for f in glob.glob( f ): shutil.rmtree( f )
        elif o == '-d':
            f = 'run' + os.sep + '[0-9][0-9]'
            for f in glob.glob( f ): shutil.rmtree( f )
        else: sys.exit( 'Unknown option: %s %s' % ( o, v ) )

    # Locations
    initdir = os.path.abspath( os.getcwd() )
    srcdir  = os.path.abspath( os.path.dirname( argv[0] ) )

    # Read and prep input files
    f = srcdir + os.sep + 'in' + os.sep + 'defaults.py'
    params = pprep( pread( [ f ] + infiles ) )
    print dir( params )

    # Make directories
    try: os.mkdir( 'tmp' )
    except: pass
    try: os.mkdir( 'run' )
    except: pass

    # Run count
    count = glob.glob( 'run' + os.sep + '[0-9][0-9]' )
    try: count = count[-1].split( os.sep )[-1]
    except: count = 0
    count = '%02d' % ( int( count ) + 1 )

    # Configure machine
    host, machine, maxnodes, maxcpus, maxram, rate, maxmm = config( machine )
    print 'Machine: ' + machine

    # Number of processors
    np3 = params.np
    if not mode and maxnodes*maxcpus == 1: mode = 's'
    if mode == 's': np3 = [ 1, 1, 1 ]
    np = np3[0] * np3[1] * np3[2]
    if not mode:
        mode = 's'
        if np > 1: mode = 'p'
    nodes = min( maxnodes, ( np - 1 ) / maxcpus + 1 )
    ppn = ( np - 1 ) / nodes + 1
    cpus = min( maxcpus, ppn )

    # Domain size
    nm3 = [ ( params.nn[i] - 1 ) / np3[i] + 3 for i in range(3) ]
    i = params.faultnormal - 1
    if i >= 0: nm3[i] = nm3[i] + 2
    nm = nm3[0] * nm3[1] * nm3[2]

    # RAM and Wall time usage
    floatsize = 4
    if params.oplevel in (1,2): nvars = 20
    elif params.oplevel in (3,4,5): nvars = 23
    else: nvars = 44
    ramproc = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * 1.5
    ramnode = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * ppn
    sus = ( params.nt + 10 ) * ppn * nm / cpus / rate / 3600000 * nodes * maxcpus
    mm  = ( params.nt + 10 ) * ppn * nm / cpus / rate / 60000 * 1.5 + 10
    if maxmm > 0: mm = min( maxmm, mm )
    hh = mm / 60
    mm = mm % 60
    walltime = '%d:%02d:00' % ( hh, mm )
    print 'Procs: %s of %s' % ( np, maxnodes * maxcpus )
    print 'Nodes: %s of %s' % ( nodes, maxnodes )
    print 'RAM: %sMb of %sMb per node' % ( ramnode, maxram )
    print 'Time limit: ' + walltime
    print 'SUs: %s' % sus
    if ppn > maxcpus:
        print 'Warning: exceding available CPUs per node (%s)' % maxcpus
    if ramnode > maxram:
        print 'Warning: exceding available RAM per node (%sMb)' % maxram

    # Set-up and run
    if not setup: return
    if subprocess.call( [ srcdir+os.sep+'setup.sh', '-'+mode+optimize ] ):
        sys.exit( 'Error building code' )

    # Setup run directory
    rundir = 'run' + os.sep + str( count )
    print 'Run directory: ' + rundir
    os.mkdir( rundir )
    files = infiles + [
        'tmp' + os.sep + 'sord.tgz',
        'tmp' + os.sep + 'sord-' + mode,
        'sh' + os.sep + 'clean' ]
    if optimize == 'g':
        files += glob.glob( 'src' + os.sep + '*.f90' )
    for f in files:
        shutil.copy( f, rundir )

    # Write input file
    rundir = os.path.abspath( rundir )
    os.chdir( rundir )
    log = file( 'log', 'w' )
    log.write( starttime + ': SORD setup started\n' )
    pwrite( 'sord-input.py' )
    for f in glob.glob( '*' ): os.chmod( f, 444 )
    for f in ( 'data', 'out', 'prof', 'stats', 'debug', 'checkpoint' ):
        os.mkdir( f )

    # Template variables
    code = 'sord'
    pre = ''
    bin = './sord-' + mode
    post = ''
    login = os.getlogin()
    try: email = file( 'email', 'r' ).read()
    except: email = login
    rundate = time.asctime()
    os_ = os.uname()[3]

    # Process templates
    os.chdir( srcdir + os.sep + 'templates' )
    templates = 'default'
    if os.path.isdir( machine ): templates = machine
    templates = glob.glob( templates + os.sep + '*' ) + [ 'runmeta.py' ]
    for f in templates:
        ff = rundir + os.sep + os.path.basename( f )
        out = file( f, 'r' ).read() % locals()
        file( ff, 'w' ).write( out )
        shutil.copymode( f, ff )

    # Data directory
    if params.datadir:
        os.chdir( initdir )
        datadir = os.path.abspath( params.datadir )
        os.chdir( rundir + os.sep + 'data' )
        for f in os.listdir( datadir ):
            ff = os.path.basename( f )
            os.symlink( f, ff )
        endian = file( 'endian', 'r' ).read()
        assert endian[0] == sys.byteorder[0]

    # Run or que job
    os.chdir( rundir )
    if run == 'q':
        print 'que'
        if subprocess.call( '.' + os.sep + 'que' ):
            sys.exit( 'Error queing job' )
    elif run:
        print 'run -' + run
        if suprocess.call( [ '.' + os.sep + 'run', '-' + run ] ):
            sys.exit( 'Error running job' )

#------------------------------------------------------------------------------#

# Configure machine attributes
def config( machine=None ):
    host = os.uname()[1]
    if not machine:
        if   host == 'cluster.geo.berkeley.edu': machine = 'calgeo'
        elif host == 'master': machine = 'babieca'
        elif host == 'ds011':  machine = 'datastar32'
        elif host[:2] == 'ds': machine = 'datastar'
        elif host[:2] == 'tg': machine = 'tgsdsc'
        else: machine = host
    machines = {
        'wide':       ( 1,   2,  3800,   500,     0 ),
        'kim':        ( 1,   2,  800,    500,     0 ),
        'phim':       ( 1,   1,  2800,   400,     0 ),
        'altai':      ( 1,   8,  30000,  100,     0 ),
        'calgeo':     ( 16,  4,  1500,   500,     0 ),
        'babieca':    ( 32,  2,  1800,   100,     0 ),
        'tgsdsc':     ( 256, 2,  3000,   1000, 1080 ),
        'datastar':   ( 265, 8,  13500,  500,  1080 ),
        'datastar32': ( 5,   32, 124000, 500,  1080 ) }
    return host, machine, machines[machine]

# Read input files
def pread( infiles ):
    p = imp.load_source( 'p', infiles[0] )
    for f in infiles[1:]:
        print f
        #f = os.path.abspath( f )
        pp = imp.load_source( 'pp', f )
        for key in dir( pp ):
            if key is 'io':
                p.io += pp.io
            elif key[:2] is not '__' and key is not 's_':
                if not hasattr( p, key ):
                    sys.exit( 'Unknown SORD parameter: %r in %s' % ( key, pp.__file__ ) )
                setattr( p, key, getattr( pp, key ) )

# Prepare input
def pprep( p ):

    # hypocenter
    ii = list( p.ihypo )
    for i in range( 3 ):
        if ii[i] == 0: ii[i] = p.nn[i] / 2
        if ii[i] < 0:  ii[i] + p.nn[i] + 1
        if ii[i] < 1 or ii[i] > p.nn[i]: sys.exit( 'ihypo %s out of bounds' % ii )
    p.ihypo = tuple( ii )

    # boundary conditions
    i1 = list( p.i1bc )
    i2 = list( p.i2bc )
    i = abs( p.faultnormal ) - 1
    if i >= 0:
        if ii[i] == nn[i]: sys.exit( 'ihypo %s out of bounds' % ii )
        if ii[i] == nn[i] - 1: i1[i] = -2
        if ii[i] == 1:         i2[i] = -2
    p.i1bc = tuple( i1 )
    p.i2bc = tuple( i2 )

    # PML region
    i1 = 0, 0, 0
    i2 = p.nn + ( 1, )
    if p.npml > 0:
        i1 = where( p.bc1 == 10, p.npml, i1 )
        i2 = where( p.bc2 == 10, p.npml, i2 )
    for i in range( 3 ):
        if i1[i] > i2[i]: sys.exit( 'model too small for PML' )
    p.i1pml = i1
    p.i2pml = i2

    # I/O regions
    io = []
    n = p.nn + [ p.nt ]
    for f in params.io:
        f = list( f )
        mode = f[0]
        field = f[1]
        readable = set([
            'x1', 'x2', 'x3', 'rho', 'vp', 'vs', 'gam',
            'mus', 'mud', 'dc' , 'co',
            'ts1', 'ts2', 'tn',
            'sxx', 'syy', 'szz', 'syz', 'szx', 'sxy', ])
        writable = set([
            'x1', 'x2', 'x3', 'rho', 'vp', 'vs',
            'u1', 'u2', 'u3', 'um2',
            'v1', 'v2', 'v3', 'vm2', 'pv2',
            'a1', 'a2', 'a3', 'am2',
            'wxx', 'wyy', 'wzz', 'wyz', 'wzx', 'wxy', 'wm',
            'mus', 'mud', 'dc', 'co',
            'ts1', 'ts2', 'ts3', 'tsm', 'tn', 'fr',
            'su1', 'su2', 'su3', 'sum', 'sl',
            'sv1', 'sv2', 'sv3', 'svm', 'psv',
            'sa1', 'sa2', 'sa3', 'sam',
            'nhat1', 'nhat2', 'nhat3', 'trup', 'tarr' ])
        if mode[0] in 'r=':
            if field not in readable: sys.exit( 'unknown input var: %s'  % f )
        elif mode[0] is 'w':
            if field not in writable: sys.exit( 'unknown output var: %s' % f )
        else: sys.exit( 'unknown mode in: %r' % f )
        di = 1, 1, 1, 1
        nb = 1
        cellval = set([
            'w', 'rho', 'vp', 'vs', 'gam' ])
        if mode[1] == 'i':
            i1, i2, di, nb = f[2:]
        elif mode[1] == '*':
            mode[1] = 'i'
            nb = f[2:]
            i1 =  1,  1,  1,  0
            i2 = -1, -1, -1, -1
        elif mode[1] == '0':
            mode[1] = 'i'
            i1 =  1,  1,  1,  0
            i2 = -1, -1, -1,  0
        elif mode[1] == '1':
            mode[1] = 'i'
            i1 =  1,  1,  1, -1
            i2 = -1, -1, -1, -1
        elif mode[1] == 'n':
            mode[1] = 'i'
            i1 = f[2:] + (  0, )
            i2 = f[2:] + ( -1, )
            nb = p.itio
        if mode[1] == 'i':
            i1 = list( i1 )
            i2 = list( i2 )
            for i in range(4):
                if i1[i] < 0: i1[i] + n[i] + 1
                if i2[i] < 0: i2[i] + n[i] + 1
                if di[i] < 0: di[i] + n[i] + 1
                if i1[i] < 1 or i1[i] > n[i]: sys.exit( 'bad zone: %s' % f )
                if i2[i] < 1 or i2[i] > n[i]: sys.exit( 'bad zone: %s' % f )
                if di[i] < 1 or di[i] > n[i]: sys.exit( 'bad zone: %s' % f )
            f = [ mode, field, tuple(i1), tuple(i2), di, nb ]
        io += [ f ]
    p.io = io
    return p

# Write input files
def pwrite( filename ):
    f = file( filename, 'w' )
    f.write( '# Auto-generated SORD input file' )
    for key in dir( params ):
        if key[:2] != '__' and key != 'io':
            f.write( '%s = %r\n' % ( key, getattr( params, key ) ) )
    f.write( 'io = [\n' )
    for line in params.io: f.write( repr( line ) + ',\n' )
    f.write( ']\n' )

# Field properties
def fieldprops( field ):
    props = {
        'x1':( 'X',                            'x' ),
        'x2':( 'Y',                            'y' ),
        'x3':( 'Z',                            'z' ),
        'x':( 'Position',                     '|X|', 'x', 'y', 'z' ),
        'rho':( 'Density',                      '\rho' ),
        'vp':( 'P-wave velocity',              'V_p' ),
        'vs':( 'S-wave velocity',              'V_s' ),
       #'mu':( '\mu',                          '\mu' ),
       #'lam':( '\lambda',                      '\lambda' ),
        'v':( 'Velocity',                     '|V|', 'V_x', 'V_y', 'V_z' ),
        'u':( 'Displacement',                 '|U|', 'U_x', 'U_y', 'U_z' ),
        'w':( 'Stress', '|W|', 'W_{xx}', 'W_{yy}', 'W_{zz}', 'W_{yz}', 'W_{zx}', 'W_{xy}' ),
        'a':( 'Acceleration',                 '|A|', 'A_x', 'A_y', 'A_z' ),
        'vm2':( 'Velocity',                     '|V|' ),
        'um2':( 'Displacement',                 '|U|' ),
        'wm2':( 'Stress',                       '|W|' ),
        'am2':( 'Acceleration',                 '|A|' ),
        'pv2':( 'Peak velocity',                '|V|_{peak}' ),
        'nhat':( 'Fault surface normals',        '|n|', 'n_x', 'n_y', 'n_z' ),
        'mus':( 'Static friction coefficient',  '\mu_s' ),
        'mud':( 'Dynamic friction coefficient', '\mu_d' ),
        'dc':( 'Slip weakening sistance',      'D_c' ),
        'co':( 'Cohesion',                     'co' ),
        'sv':( 'Slip velocity',                '|V_s|', 'V_s_x', 'V_s_y', 'V_s_z' ),
        'su':( 'Slip',                         '|U_s|', 'U_s_x', 'U_s_y', 'U_s_z' ),
        'ts':( 'Shear traction',               '|T_s|', 'T_s_x', 'T_s_y', 'T_s_z' ),
        'sa':( 'Slip acceleration',            '|A_s|', 'A_s_x', 'A_s_y', 'A_s_z' ),
        'svm':( 'Slip velocity',                '|V_s|' ),
        'sum':( 'Slip',                         '|U_s|' ),
        'tsm':( 'Shear traction',               '|T_s|' ),
        'sam':( 'Slip acceleration',            '|A_s|' ),
        'tn':( 'Normal traction',              'T_n' ),
        'fr':( 'Friction',                     'f' ),
        'sl':( 'Slip path length',             'l' ),
        'psv':( 'Peak slip velocity',           '|V_s|_{peak}' ),
        'trup':( 'Rupture time',                 't_{rupture}' ),
        'tarr':( 'Arrest time',                  't_{arrest}' ),
    }

# If called from the command line
if __name__ == "__main__":
    sord( sys.argv )

