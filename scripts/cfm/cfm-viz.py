#!/usr/bin/env ipython --gui=wx
"""
SCEC Community Fault Model Visualizer
=====================================

A simple tool for exploring the CFM

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
"""
import numpy as np
import pyproj
from enthought.mayavi import mlab
import cst

# parameters
fig_name = 'SCEC Community Fault Model'
print '\n%s\n' % fig_name
extent = (-122.0, -114.0), (31.5, 37.5)
faults = cst.data.cfm()
proj = pyproj.Proj(proj='tmerc', lon_0=-118.0, lat_0=34.5)
resolution = 'high'
view_azimuth = -90
view_elevation = 45
view_angle = 15
opacity = 0.3
opacity = 1.0
color_bg = 1.0, 0.0, 0.0
color_hl = 1.0, 1.0, 0.0

# setup figure
fig = mlab.figure(fig_name, (1,1,1), (0,0,0), size=(1280, 720))
fig.scene.disable_render = True

# topography
topo, extent = cst.data.topo(extent, mesh=True)
x, y, z = topo
x, y = proj(x, y)
mlab.mesh(x, y, z, color=(1,1,1), opacity=0.3)

# base map
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
mlab.plot3d(x, y, z, color=(0,0,0), line_width=1, tube_radius=None)

# fault surfaces
print '\nReading fault surfaces:\n'
names = {}
coords = []
for f in faults:
    f = cst.data.cfm(f)
    if f is None:
        continue
    print('    ' + repr(f.name))
    x, y = proj(f.lon, f.lat)
    z, t = f.z, f.tri.T
    s = mlab.triangular_mesh(x, y, z, t, representation='surface', color=color_hl)
    x, y = proj(f.lon0, f.lat0)
    z = f.z0
    a = s.actor.actor
    coords += [[x, y, z, a]]
    names[a] = f.name

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
            current[0].property.color = color_bg
        else:
            i = len(actors) // 2
            for a in names.keys():
                a.property.opacity = opacity
                a.property.color = color_bg
        a = actors[i]
        a.property.opacity = 1.0
        a.property.color = color_hl
        fig.name = names[a]
        current[0] = a
    elif k == '\\' and current[0]:
        current[0] = None
        fig.name = fig_name
        for a in names.keys():
            a.property.opacity = 1.0
            a.property.color = color_hl
    elif ord(k) == 8: # delete key
        mlab.view(view_azimuth, view_elevation)
        fig.scene.camera.view_angle = view_angle
    elif k in '/?h':
        print __doc__
    fig.scene.disable_render = False
    return

# finish up
fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
mlab.view(view_azimuth, view_elevation)
fig.scene.camera.view_angle = view_angle
fig.scene.disable_render = False
mlab.show()
print "\nPress H in the figure window for help."

