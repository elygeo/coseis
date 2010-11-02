#!/usr/bin/env python
"""
Get
"""
import os, glob
from subprocess import Popen, PIPE
import cst

# moment tensor
event_id = 14383980
mts = cst.source.scsn_mts( event_id )
date = mts['origin_time'].split()[0].split('/')
date = '/'.join( (date[2], date[0], date[1]) )
m = mts['double_couple_clvd']
source1 =  m['myy'],  m['mxx'],  m['mzz']
source2 = -m['mxz'], -m['myz'],  m['mxy']
print source1
print source2

# seismograms
if not os.path.exists( 'run/data' ):
    Popen( 'stp', stdin=PIPE ).communicate( """
        mseed
        gain on
        trig -net ci -chan hn_ -radius 50 %s
        output station-list.txt
        sta -l -net ci -chan bh_ %s
        output off
    """ % (event_id, date) )
    if not os.path.exists( 'run' ):
        os.mkdir( 'run' )
    os.rename( str( event_id ), 'run/data' )

# stations
stations = set( '.'.join( s.split( '.' )[1:3] ) for s in glob.glob( 'run/data/*mseed' ) )
locations = []
for s in open( 'station-list.txt' ).readlines():
    if s.split()[0] in stations:
        locations += [s]
open( 'station-list.txt', 'w' ).writelines( locations )

