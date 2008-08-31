#!/usr/bin/env python

import os, sys, getopt, time, glob, shutil

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
machine = os.uname()[1]
if machine == 'cluster.geo.berkeley.edu': machine = 'calgeo'
elif machine == 'master': machine = 'babieca'
elif machine == 'ds011':  machine = 'datastar32'
elif machine[:2] == 'ds': machine = 'datastar'
elif machine[:2] == 'tg': machine = 'tgsdsc'

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
maxnodes, maxcpus, maxram, rate, maxmm = machines[ machine ]

# Number of processors
np3 = np
if mode == 'guess' and maxnodes*maxcpus == 1: mode = 's'
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
else nvars = 44
ramproc = nm * nvars * floatsize / 1024 / 1024 + 10 ) * 1.5
ramnode = nm * nvars * floatsize / 1024 / 1024 + 10 ) * ppn
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

# sys.byteorder
