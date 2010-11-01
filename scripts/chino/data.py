#!/usr/bin/env python
"""
Get
"""
import os, glob
from subprocess import Popen, PIPE
import cst

# SCSN event id
eventid = 14383980

# moment tensor
mts = cst.source.scsn_mts( eventid )
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
        trig -net ci -chan bh_ -radius 50 %s
        output station-list.txt
        sta -l -net ci -chan bh_ %s
        output off
    """ % (eventid, date) )
    os.rename( str( eventid ), 'run/data' )

# stations
stations = set( '.'.join( s.split( '.' )[1:3] ) for s in glob.glob( 'tmp/*mseed' ) )
locations = []
for s in open( 'station-list.txt' ).readlines():
    if s.split()[0] in stations:
        locations += [s]
open( 'station-list.txt', 'w' ).writelines( locations )

