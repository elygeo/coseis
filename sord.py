#!/usr/bin/env python

import os, sys, getopt, time, glob, shutil

def main():

    # Log start time
    starttime = time.asctime()
    print "SORD setup"

    # Command line options
    setup = True
    run = False
    mode = 'guess'
    optimize = 'O'
    opt, argv = getopt.getopt( sys.argv[1:], 'niqspgGm:fd' )
    for o, a in opt:
        if   o == '-n': setup = False; run = False
        elif o == '-i': run = 'i'
        elif o == '-q': run = 'q'
        elif o == '-s': mode = 's'
        elif o == '-p': mode = 'p'
        elif o == '-g': optimize = 'g'
        elif o == '-G': optimize = 'g'; run = 'g'
        elif o == '-m': machine = a
        elif o == '-f':
            for f in glob.glob( 'tmp/*' ): shutil.rmtree( f )
        elif o == '-d':
            for f in glob.glob( 'run/[0-9][0-9]' ): shutil.rmtree( f )
        else: assert False, "unhandled option"

    # Locations
    infile = os.path.abspath( argv[0] )
    srcdir = os.path.abspath( os.path.dirname( sys.argv[0] ) )
    cwdir  = os.path.abspath( os.getcwd() )

    # Make directories
    if not os.path.isdir( 'tmp' ): os.mkdir( 'tmp' )
    if not os.path.isdir( 'run' ): os.mkdir( 'run' )

    # Run count
    count = glob.glob( 'run/[0-9][0-9]' )[-1].split( '/' )[-1]
    count = '%02d' % ( int( count ) + 1 )

    # Read input file
    execfile( srcdir + '/in/defaults.py' )
    execfile( infile )

    # Host
    host = os.uname()[1]
    if host == 'cluster.geo.berkeley.edu': machine = 'calgeo'
    elif host == 'master': machine = 'babieca'
    elif host == 'ds011':  machine = 'datastar32'
    elif host[:2] == 'ds': machine = 'datastar'
    elif host[:2] == 'tg': machine = 'tgsdsc'
    else: machine = host
    print 'Machine: ' + machine

    # Machine attributes
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
    maxnodes, maxcpus, maxram, rate, maxmm = machines[machine]

    # Number of processors
    np3 = np
    if mode == 'guess' and maxnodes*maxcpus == 1: mode = 's'
    print mode, maxnodes, maxcpus
    if mode == 's': np3 = [ 1, 1, 1 ]
    np = np3[0] * np3[1] * np3[2]
    if mode == 'guess':
        mode = 's'
        if np > 1: mode = 'p'
    nodes = min( maxnodes, ( np - 1 ) / maxcpus + 1 )
    ppn = ( np - 1 ) / nodes + 1
    cpus = min( maxcpus, ppn )

    # Domain size
    nm3 = [ ( nn[i] - 1 ) / np3[i] + 3 for i in range(3) ]
    i = faultnormal - 1
    if i >= 0: nm3[i] = nm3[i] + 2
    nm = nm3[0] * nm3[1] * nm3[2]

    # RAM and Wall time usage
    floatsize = 4
    if oplevel in (1,2): nvars = 20
    elif oplevel in (3,4,5): nvars = 23
    else: nvars = 44
    ramproc = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * 1.5
    ramnode = ( nm * nvars * floatsize / 1024 / 1024 + 10 ) * ppn
    sus = ( nt + 10 ) * ppn * nm / cpus / rate / 3600000 * nodes * maxcpus
    mm  = ( nt + 10 ) * ppn * nm / cpus / rate / 60000 * 1.5 + 10
    if maxmm > 0: mm = min( maxmm, mm )
    hh = mm / 60
    mm = mm % 60
    walltime = '%d:%02d:00' % ( hh, mm )
    print 'Procs: %d of %d' % ( np, maxnodes * maxcpus )
    print 'Nodes: %d of %d' % ( nodes, maxnodes )
    print 'RAM: %dMb of %dMb per node' % ( ramnode, maxram )
    print 'Time limit: ' + walltime
    print 'SUs: %d' % sus
    if ppn > maxcpus: print 'Warning: exceding available CPUs per node (%d)' % maxcpus
    if ramnode > maxram: print 'Warning: exceding available RAM per node (%dMb)' % maxram

    #------------------------------------------------------------------------------#
    # Set-up and run

    if not setup: return
    assert not os.system( srcdir + '/make.sh -' + mode + optimize )

    # Setup run directory
    rundir = 'run/$count'
    print 'Run directory: ' + rundir
    os.mkdir( rundir )
    log = file( rundir + '/log', 'w' )
    log.write( starttime + ': SORD setup started' )
    files = [
        infile,
        'tmp/sord.tgz',
        'tmp/sord-' + mode,
        'sh/clean' ]
    if optimize == 'g':
        files += glob.glob( 'src/*.f90' ):
    for f in files:
        shutil.copy( f, rundir )
    os.cwdir( rundir )
    for f in glob.glob( '*' ):
        os.chmod( f, 444 )
    os.mkdir( 'out' )
    os.mkdir( 'prof' )
    os.mkdir( 'stats' )
    os.mkdir( 'debug' )
    os.mkdir( 'checkpoint' )

    # Process input file

    # Process templates
    cfg = 'default'
    if os.path.isdir( 'py/' + machine ):
        cfg = machine
    login = os.getlogin()
    rundate = time.asctime()
    os_ = os.uname()[3]
    templates = [ srcdir + 'templates/meta.py' ]
    templates += glob.glob( srddir + '/templates/' + machine
    for f in templates:
        file( 'meta.py', 'w' ).write( % locals() )


    # sys.byteorder

if __name__ == "__main__":
    main()

