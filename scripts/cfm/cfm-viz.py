#!/usr/bin/env ipython --gui=wx
"""
SCEC Community Fault Model Visualizer

Arrow keys or mouse drag:                Rotate the view
Shift-arrow keys or mouse drag:          Pan the view
'-' and '+' keys or right mouse drag:    Zoom the view 
',' and '.' keys:                        Left/right fault selection
'<' and '>' keys:                        Up/down selection
'/' key:                                 Reset the view
'3' key:                                 Toggle stereo view
's' key:                                 Save a screen-shot

Edit this script to select by fault name or bounding region (extent).
"""
print __doc__
import numpy as np
import pyproj
from enthought.mayavi import mlab
#from enthought.tvtk.api import tvtk
import cst

# parameters
fault_extent = (-117.1, -116.1), (33.7, 34.1)
faults = [
    ([0, 1], 'cfma_san_bernardino_W_san_andreas_complete'),
    ([0, 1], 'cfma_san_andreas_coachella_alt3_complete'),
    ([0, 1, 4], 'banning_from_hypo_complete'),
]
faults = None # everything
combine = True
resolution = 'high'
resolution = 'low'
view_azimuth = -90
view_elevation = 55
view_angle = 23
opacity = 0.3

# projection
scale = 0.001
extent = (-121.5, -114.5), (30.5, 36.5)
proj = pyproj.Proj(proj='tmerc', lon_0=-117.7, lat_0=34.1, k=scale)

# CFM data
cfm = cst.data.scec_cfm()
if faults == None:
    faults = [(None, f) for f in cfm.faults]

# topography
topo, extent = cst.data.topo(extent, scale=scale)
lon, lat = extent
ddeg = 0.5 / 60.0
n = topo.shape
x = lon[0] + ddeg * np.arange(n[0])
y = lat[0] + ddeg * np.arange(n[1])
y, x = np.meshgrid(y, x)
x, y = proj(x, y)
topomesh = x, y

# base map data
if 0:
    x, y = np.c_[
        cst.data.mapdata('coaslines', resolution, extent, 10.0),
        [np.nan, np.nan],
        cst.data.mapdata('boders', resolution, extent),
    ]
    x -= 360.0
    z = cst.coord.interp2(extent, topo, (x, y))
    x, y = proj(x, y)
    mapdata = x, y, z

# setup figure
engine = mlab.get_engine()
fig = engine.current_scene
if fig is None:
    pixels = 1280, 720
    fig = mlab.figure('CFM Visualizer', (1,1,1), (0,0,0), engine, pixels)
    new_fig = True
else:
    fig = mlab.gcf()
    new_fig = False
mlab.clf()
fig.scene.disable_render = True

# base map
if 0: 
    x, y = topomesh
    mlab.mesh(x, y, topo, color=(1,1,1), opacity=0.2)
    x, y, z = mapdata
    mlab.plot3d(x, y, z, color=(0,0,0), line_width=1, tube_radius=None)

# plot fault surfaces
print 'Reading CFM surfaces:'
names = {}
titles = {}
coords = []
for segments, fault in faults:
    tsurf = cfm(fault, segments, fault_extent)
    if tsurf is None:
        continue
    hdr, phdr, xyz, tri, border, bstone = tsurf
    name = hdr['name']
    title = name.replace('cfma_', '').replace('cfm_',  '')
    title = title.replace('_', ' ').replace('-', ' ').title()
    print title
    x, y, z = xyz
    x, y = proj(x, y)
    z *= scale
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
        titles[a] = title
        coords += [[x.mean(), y.mean(), z.mean(), a]]

# sort faults by location
fig.name = titles[a]
a.property.opacity = 1.0
current_fault = a

# handle key press
def on_key_press(obj, event):
    global current_fault
    k = obj.GetKeyCode()
    if k == '/':
        mlab.view(view_azimuth, view_elevation)
        fig.scene.camera.view_angle = view_angle
        return
    m = fig.scene.camera.view_transform_matrix.to_array()
    if k in ',.':
        mx, my, mz, mt = m[0]
        d = {',': -1, '.': 1}[k]
    elif k in '<>':
        mx, my, mz, mt = m[1]
        d = {'<': -1, '>': 1}[k]
    else:
        return
    a = sorted((mx*x + my*y + mz*z + mt, a) for x, y, z, a in coords)
    a = [a for r, a in a]
    i = (a.index(current_fault) + d) % len(a)
    a = a[i]
    fig.name = titles[a]
    a.property.opacity = 1.0
    current_fault.property.opacity = opacity
    current_fault = a
    return

# finish up
if new_fig:
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
mlab.view(view_azimuth, view_elevation)
fig.scene.camera.view_angle = view_angle
fig.scene.disable_render = False
mlab.show()

