#!/usr/bin/env ipython --gui=wx
"""
SCEC Community Fault Model Visualizer
=====================================

Keyboard Controls
-----------------

Fault selection                   [ ]
Reset fault selection               \\
Rotate the view                Arrows          
Pan the view             Shift-Arrows    
Zoom the view                     - =             
Reset the view                 Delete               
Toggle stereo view                  3               
Save a screen-shot                  S               
Help                              h ?

Note
----

Edit this script to select by fault
name or bounding region (extent).
"""
import numpy as np
import pyproj
from enthought.mayavi import mlab
import cst

# parameters
fig_name = __doc__.splitlines()[1]
print '\n%s\n' % fig_name
extent = (-121.5, -114.5), (30.5, 36.5)
extent = (-118, -115), (32.5, 35)
extent = (-119, -114), (32, 36)
fault_extent = (-117.1, -116.1), (33.7, 34.1)
faults = [
    ([0, 1], 'cfma_san_bernardino_W_san_andreas_complete'),
    ([0, 1], 'cfma_san_andreas_coachella_alt3_complete'),
    ([0, 1, 4], 'banning_from_hypo_complete'),
]
faults = None # everything
combine = True
resolution = 'high'
view_azimuth = -90
view_elevation = 55
view_angle = 15
opacity = 0.3
zscale = 1.0

# projection
scale = 0.001
proj = pyproj.Proj(proj='tmerc', lon_0=-117.7, lat_0=34.1, k=scale)

# CFM data
cfm = cst.data.scec_cfm()
if faults == None:
    faults = [(None, f) for f in cfm.faults]

# topography
topo, extent = cst.data.topo(extent, scale=scale, mesh=True)
x, y, z = topo
x, y = proj(x, y)
topo = x, y, z

# base map data
ddeg = 0.5 / 60.0
x, y = np.c_[
    cst.data.mapdata('coaslines', resolution, extent, 10.0, delta=ddeg),
    [np.nan, np.nan],
    cst.data.mapdata('boders', resolution, extent, delta=ddeg),
]
x -= 360.0
z = cst.coord.interp2(extent, topo[2], (x, y))
x, y = proj(x, y)
i = np.isnan(z)
x[i] = np.nan
y[i] = np.nan
mapdata = x, y, z

# setup figure
engine = mlab.get_engine()
fig = engine.current_scene
if fig is None:
    pixels = 1280, 720
    fig = mlab.figure(fig_name, (1,1,1), (0,0,0), engine, pixels)
    new_fig = True
else:
    fig = mlab.gcf()
    new_fig = False
mlab.clf()
fig.scene.disable_render = True

# base map
x, y, z = topo
mlab.mesh(x, y, z, color=(1,1,1), opacity=opacity)
x, y, z = mapdata
mlab.plot3d(x, y, z, color=(0,0,0), line_width=1, tube_radius=None)

# plot fault surfaces
print '\nReading fault surfaces:\n'
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
    print '    %s' % name
    x, y, z = xyz
    x, y = proj(x, y)
    z *= scale * zscale
    if combine:
        tri = [np.hstack(tri)]
    for t in tri:
        s = mlab.triangular_mesh(x, y, z, t.T, representation='surface')
        a = s.actor.actor
        names[a] = name
        titles[a] = title
        coords += [[x.mean(), y.mean(), z.mean(), a]]

# handle key press
def on_key_press(obj, event, current=[None]):
    k = obj.GetKeyCode()
    fig.scene.disable_render = True
    if k in '[]':
        m = fig.scene.camera.view_transform_matrix.to_array()
        mx, my, mz, mt = m[0]
        actors = [(mx*x + my*y + mz*z + mt, a) for x, y, z, a in coords]
        actors = [a for r, a in sorted(actors)]
        if current[0]:
            d = {'[': -1, ']': 1}[k]
            i = (actors.index(current[0]) + d) % len(actors)
            current[0].property.opacity = opacity
        else:
            i = len(actors) // 2
            for a in names.keys():
                a.property.opacity = opacity
        a = actors[i]
        a.property.opacity = 1.0
        fig.name = titles[a]
        current[0] = a
    elif k == '\\' and current[0]:
        current[0] = None
        fig.name = fig_name
        for a in names.keys():
            a.property.opacity = 1.0
    elif ord(k) == 8: # delete key
        mlab.view(view_azimuth, view_elevation)
        fig.scene.camera.view_angle = view_angle
    elif k in '/?h':
        print __doc__
    fig.scene.disable_render = False
    return

# finish up
if new_fig:
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
mlab.view(view_azimuth, view_elevation)
fig.scene.camera.view_angle = view_angle
fig.scene.disable_render = False
mlab.show()
print "\nPress H in the figure window for help."

