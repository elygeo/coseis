#!/usr/bin/env python
"""
Get
"""
import os, sys, glob, time, subprocess
import cst

# moment tensor
event_id = 14383980
mts = cst.source.scsn_mts( event_id )
date = mts['origin_time'].split( 'T' )[0].replace('-', '/')
m = mts['double_couple_clvd']
source1 =  m['myy'],  m['mxx'],  m['mzz']
source2 = -m['mxz'], -m['myz'],  m['mxy']

# seismograms
if not os.path.exists( 'run/data' ):
    for i in range( 60 ):
        print( 'STP, try %s' % i )
        p = subprocess.Popen( 'stp', stdin=subprocess.PIPE )
        p.communicate( """
            sac
            gain off
            trig -net ci -chan hn_ -radius 20 %s
            output station-list.txt
            sta -l -net ci -chan hn_ %s
            output off
        """ % (event_id, date) )
        if not p.returncode:
            break
        time.sleep(1)
    if p.returncode:
        sys.exit( 'problem running STP' )
    if not os.path.exists( 'run' ):
        os.mkdir( 'run' )
    os.rename( str( event_id ), 'run/data' )

# stations
records = glob.glob( 'run/data/*.sac' )
stations = set( '.'.join( r.split( '.' )[1:3] ) for r in records )
locations = []
meta = ''
for sta in open( 'station-list.txt' ).readlines():
    s = sta.split()[0]
    if s in stations and s not in ['CI.CRN']:
        locations += [sta]
        meta += 'meta ' + s.replace('.', ' ') + '\n'
if not locations:
    sys.exit( 'no stations found' )
open( 'station-list.txt', 'w' ).writelines( locations )

# download station metadata
if not os.path.exists( 'run/stations' ):
    os.mkdir( 'run/stations' )
    os.chdir( 'run/stations' )
    for i in range( 60 ):
        print( 'STP, try %s' % i )
        p = subprocess.Popen( 'stp', stdin=subprocess.PIPE )
        p.communicate( meta )
        if not p.returncode:
            break
        time.sleep(1)
    if p.returncode:
        sys.exit( 'problem running STP' )

