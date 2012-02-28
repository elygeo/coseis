#!/usr/bin/env ipython --gui=wx
"""
SCEC Community Fault Model Visualizer

Arrow keys or mouse drag:                Rotate the view
Shift-arrow keys or mouse drag:          Pan the view
'-' and '+' keys or right mouse drag:    Zoom the view 
',' and '.' keys or mouse click:         Fault selection
'/' key:                                 Reset the view
'3' key:                                 Toggle stereo view
's' key:                                 Save a screen-shot

Edit this script to select by fault name or bounding region (extent).
"""
print __doc__
import numpy as np
import pyproj
from enthought.mayavi import mlab
import cst

# parameters
faults = [
    ([0, 1], 'cfma_san_bernardino_W_san_andreas_complete'),
    ([0, 1], 'cfma_san_andreas_coachella_alt3_complete'),
    ([0, 1, 4], 'banning_from_hypo_complete'),
]
faults = None # None means everything
extent = (-117.1, -116.1), (33.7, 34.1)
sort_vector = 1.0, -1.0, 0.0
geographic = False
geographic = True
coastline = False
coastline = True
combine = True
opacity = 0.3

# setup CFM
cfm = cst.data.scec_cfm()
if faults == None:
    faults = [(None, f) for f in cfm.faults]

# projection
proj = pyproj.Proj(**cfm.projection)
if not geographic:
    x, y = extent
    extent = proj(x, y)

# setup figure
fig = mlab.gcf()
mlab.clf()
fig.scene.disable_render = True
fig.name = 'SCEC Community Fault Model Visualizer'
fig.scene.background = 1, 1, 1
fig.scene.foreground = 0, 0, 0

# coastline
if coastline:
    map_extent = (-119, -114), (32.5, 36)
    x, y = np.c_[
        cst.data.mapdata('coaslines', 'high', map_extent, 10.0),
        [np.nan, np.nan],
        cst.data.mapdata('boders', 'high', map_extent),
    ]
    z = np.zeros_like(x)
    if geographic:
        x -= 360.0
    else:
        x, y = proj(x, y)
    mlab.plot3d(x, y, z, color=(0,0,0), tube_radius=None, line_width=1.0)

# plot fault surfaces
print 'Reading CFM surfaces:'
names = {}
actors = {}
for segments, fault in faults:
    tsurf = cfm(fault, segments, extent, geographic)
    if tsurf is None:
        continue
    hdr, phdr, xyz, tri, border, bstone = tsurf
    name = hdr['name'].replace('_', ' ').replace('-', ' ').title()
    print name
    x, y, z = xyz
    if geographic:
        z *= 0.00001
    a, b, c = sort_vector
    sort_key = (a * x + b * y + c * z).mean()
    if combine:
        tri = [np.hstack(tri)]
    for t in tri:
        s = mlab.triangular_mesh(
            x, y, z, t.T,
            representation='surface',
            opacity = opacity,
        )
        a = s.actor.actor
        names[a] = name
        actors[sort_key] = a

# sort faults by location
actors = [actors[k] for k in sorted(actors)]
a = actors[0]
fig.name = names[a]
a.property.opacity = 1.0
current_fault = a

# handle key press
def on_key_press(obj, event):
    global current_fault
    k = obj.GetKeyCode()
    if k == '/':
        mlab.view(-90, 55)
        fig.scene.camera.view_angle = 20
        return
    d = {',': -1, '.': 1}
    if k not in d:
        return
    i = (actors.index(current_fault) + d[k]) % len(actors)
    a = actors[i]
    print names[a]
    fig.name = names[a]
    a.property.opacity = 1.0
    current_fault.property.opacity = opacity
    current_fault = a
    return

# handle mouse pick
def on_mouse_pick(picker):
    global current_fault
    a = picker.actor
    if a is None:
        return
    print names[a]
    if a is current_fault:
        return
    fig.name = names[a]
    a.property.opacity = 1.0
    current_fault.property.opacity = opacity
    current_fault = a
    return

# finish up
mlab.view(-90, 55)
fig.scene.camera.view_angle = 20
fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
fig.on_mouse_pick(on_mouse_pick)
fig.scene.disable_render = False
mlab.show()

