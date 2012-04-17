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
nsegs = cst.data.cfm()

# parameters
fig_name = 'SCEC Community Fault Model'
print '\n%s\n' % fig_name
extent = (-119, -114), (32, 36)
extent = (-121.5, -114.5), (30.5, 36.5)
fault_extent = (-118, -115), (33, 35)
fault_extent = (-117.1, -116.1), (33.7, 34.1)
fault_extent = extent
faults = [
    'SAFS-SAFZ-PARK-San_Andreas_fault',
    'SAFS-SAFZ-CLCZ-San_Andreas_fault-CHLM',
    'SAFS-SAFZ-CLCZ-San_Andreas_fault-CRRZ',
    'SAFS-SAFZ-MJVS-San_Andreas_fault',
    'SAFS-SAFZ-SBMT-San_Andreas_fault-alt1',
    'SAFS-SAFZ-MULT-Banning_fault-alt1',
    #('SAFS-SAFZ-MULT-Banning_fault-alt1', [0, 2]),
    'SAFS-SAFZ-COAV-Banning_fault-alt1-south',
    'SAFS-SAFZ-COAV-Southern_San_Andreas_fault-alt1',
    'GRFS-GRFZ-EAST-Garlock_fault',
    'GRFS-GRFZ-WEST-Garlock_fault',
    'PNRA-SJFZ-SBRN-San_Jacinto-Claremont_fault-alt1',
    'PNRA-SJFZ-SJCV-Claremont_fault',
    'PNRA-SJFZ-ANZA-Clark_fault-alt1-north-alt2-upper2',
    'PNRA-SJFZ-ANZA-Clark_fault-alt1-north-alt2-upper1',
    'PNRA-SJFZ-ANZA-Clark_fault-alt1-north-alt2-lower',
    'PNRA-SJFZ-ANZA-Clark_fault-alt1-south-main-alt1',
    'PNRA-ELSZ-CHNO-chino_fault-alt1-Central_Ave',
    'PNRA-ELSZ-CHNO-chino_fault-alt1-main',
    'PNRA-ELSZ-CYMT-Elsinore_fault-CFMA',
    'PNRA-ELSZ-GLIV-Glen_Ivy_fault-north-alt1',
    'PNRA-ELSZ-GLIV-Glen_Ivy_fault-south',
    'PNRA-ELSZ-JULN-Elsinore_fault-alt1-Wildomar-link',
    'PNRA-ELSZ-JULN-Elsinore_fault-alt1-north',
    'PNRA-ELSZ-JULN-Elsinore_fault-alt1-south',
    'PNRA-ELSZ-TMCL-Wildomar_fault',
    'PNRA-ELSZ-TMCL-Willard_fault-alt1',
    'OCBA-PVFZ-MULT-Palos_Verdes_fault-CFM',
    'WTRA-SCFZ-MULT-San_Cayetano_fault-CFM',
    'WTRA-SMFZ-MULT-Sierra_Madre_fault-west-alt1',
    'WTRA-SMFZ-MULT-Sierra_Madre_fault-east',
    'WTRA-SMFZ-MULT-Sierra_Madre_fault-Cucamonga_Connector',
    'WTRA-SBTS-PHLS-Puente_Hills_Thrust_fault-CH',
    'WTRA-SBTS-PHLS-Puente_Hills_Thrust_fault-LA',
    'WTRA-SBTS-PHLS-Puente_Hills_Thrust_fault-Richfield',
    'WTRA-SBTS-PHLS-Puente_Hills_Thrust_fault-SFS',
]
#faults = [[(k, [i])] for k in faults for i in range(nsegs[k])]
patterns = [
]
patterns = [
    'PNRA-NIRC-',
]
if 1:
    faults = []
    for f in sorted(nsegs):
        for p in patterns:
            if p in f:
                faults.append(f)
                break
resolution = 'high'
resolution = 'intermediate'
view_azimuth = -90
view_azimuth = 0
view_elevation = 55
view_elevation = 0
view_angle = 15
opacity = 0.3
zscale = 1.0
vlim = -12.0 * zscale, 0.0

# projection
scale = 0.001
proj = pyproj.Proj(proj='tmerc', lon_0=-117.7, lat_0=34.1, k=scale)

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
coords = []
for f in faults:
    f = cst.data.cfm(f, fault_extent)
    if f is None:
        continue
    print '    %s' % f.name
    x, y, z = f.llz
    x, y = proj(x, y)
    z *= scale * zscale
    t = f.tri.T
    s = mlab.triangular_mesh(x, y, z, t, representation='surface', vmin=vlim[0], vmax=vlim[1])
    a = s.actor.actor
    names[a] = f.name
    x, y = proj(f.lon, f.lat)
    z = f.dep * scale * zscale
    coords += [[x, y, z, a]]

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
        fig.name = names[a]
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

