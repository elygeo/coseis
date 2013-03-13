#!/usr/bin/env python
"""
Get event data
"""
import os, json
import cst

# parameters
event_id = 14383980
stations = [
    'CHN', 'MLS', 'PDU', 'FON', 'BFS', 'RVR',
    'PSR', 'RIO', 'KIK', 'GSA', 'HLL', 'DEC', 'CHF', 'LFP',
    'FUL', 'SRN', 'PLS', 'OGC', 'BRE', 'LLS', 'SAN', 'STG', 'SDD',
    'OLI', 'RUS', 'DLA', 'LTP', 'STS', 'LAF', 'WTT', 'USC', 'SMS',
]

# data directory
path = os.path.join('run', 'data')
os.makedirs(path)

# moment tensor
f = os.path.join(path, '%s.mts.txt')
if os.path.exists(f):
    mts = json.load(f)
else:
    mts = cst.scedc.mts(event_id)
    json.dump(mts, f)
m = mts['double_couple_clvd']
source1 =  m['myy'],  m['mxx'],  m['mzz']
source2 = -m['mxz'], -m['myz'],  m['mxy']

# open STP connection
with cst.scedc.stp('scedc') as stp:

    # stations coordinates
    date = mts['origin_time'].split('T')[0].replace('-', '/')
    loc = stp('sta -l -net ci -chan hn_ %s' % date)
    loc = loc[0].split('\n')[1:-1]
    locations = []
    for sta in loc:
        s = sta.split()[0].split('.')[1]
        if s in stations:
            locations += [sta]
    f = os.path.join(path, 'station-list.txt')
    open(f, 'w').writelines(s + '\n' for s in locations)

    # download waveforms
    stp(['sac', 'gain on'])
    for sta in stations:
        stp('trig -net ci -chan _n_ -sta %s %s' % (sta, event_id), path)

