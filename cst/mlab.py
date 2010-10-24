"""
Mayavi utilities
"""
import numpy as np
import viz

def colormap( *args, **kwargs ):
    """
    Mayavi colormap. See viz.colormap for details.
    """
    cmap = viz.colormap( *args, **kwargs )
    v, r, g, b, a = cmap
    if len( v ) < 1001:
        vi = np.linspace( v[0], v[-1], 2001 )
        r = np.interp( vi, v, r )
        g = np.interp( vi, v, g )
        b = np.interp( vi, v, b )
        a = np.interp( vi, v, a )
        cmap = np.array( [r, g, b, a] )
    return 255 * cmap.T

def text3d( x, y, z, s, bcolor=None, bwidth=0.5, bn=16, **kwargs ):
    """
    Mayavi text3d command augmented with poor man's bold.
    """
    from enthought.mayavi import mlab
    h = []
    if bcolor is not None:
        args = kwargs.copy()
        args['color'] = bcolor
        for i in range( bn ):
            phi = 2.0 * np.pi * i / bn
            x_ = x + bwidth * np.cos( phi )
            y_ = y + bwidth * np.sin( phi )
            h += [ mlab.text3d( x_, y_, z, s, **args ) ]
            h[-1].actor.property.lighting = False
    h += [ mlab.text3d( x_, y_, z, s, **kwargs ) ]
    h[-1].actor.property.lighting = False
    return h

def screenshot( fig, format=None, mag=None, aa_frames=8 ):
    """
    Mayavi screenshot.
    """
    from enthought.tvtk.api import tvtk
    #fig.scene._lift()
    x, y = size = tuple( fig.scene.get_size() )
    aa_frames0 = fig.scene.render_window.aa_frames
    fig.scene.render_window.aa_frames = aa_frames
    if mag:
        x, y = mag * x, mag * y
        fig.scene.set_size( (x, y) )
    drsave = fig.scene.disable_render
    fig.scene.disable_render = False
    fig.scene.render()
    fig.scene.disable_render = drsave
    img = tvtk.UnsignedCharArray()
    fig.scene.render_window.get_pixel_data( 0, 0, x-1, y-1, 1, img )
    img = img.to_array().reshape( (y, x, 3) )[::-1,:]
    fig.scene.render_window.aa_frames = aa_frames0
    if mag:
        fig.scene.set_size( size )
        fig.scene.render()
    return( img )

class digital_clock():
    """
    Displays a digital clock with the format H:MM or M:SS in Mayavi.
    Calling the digital clock object with an argument of minutes or seconds sets the time.
    """
    def __init__( self, x0=0, y0=0, z0=0, scale=1.0, color=(0,1,0), line_width=3, **kwargs ):
        from enthought.mayavi import mlab
        fig = mlab.gcf()
        render = fig.scene.disable_render
        fig.scene.disable_render = True
        xx = x0 + scale / 200.0 * np.array( [
            [  -49,  -40, np.nan ],
            [   51,   60, np.nan ],
            [  -60,  -51, np.nan ],
            [   40,   49, np.nan ],
            [  -30,   50, np.nan ],
            [  -40,   40, np.nan ],
            [  -50,   30, np.nan ],
        ] )
        yy = y0 + scale / 200.0 * np.array( [
            [   10,   90, np.nan ],
            [   10,   90, np.nan ],
            [  -90,  -10, np.nan ],
            [  -90,  -10, np.nan ],
            [  100,  100, np.nan ],
            [    0,    0, np.nan ],
            [ -100, -100, np.nan ],
        ] )
        zz = z0 * np.ones_like( xx )
        glyphs = [5], [0,2,4,5,6], [0,3], [0,2], [2,4,6], [1,2], [1], [0,2,5,6], [], [2]
        hh = []
        for g in glyphs:
            i = np.array( [ i for i in range(7) if i not in g ] )
            h = []
            for x in -0.875, 0.125, 0.875:
                h += [ mlab.plot3d(
                    scale * x + xx[i].flatten(), yy[i].flatten(), zz[i].flatten(),
                    color=color,
                    tube_radius=None,
                    line_width=line_width,
                    **kwargs
                ) ]
            hh += [h]
        self.glyphs = hh
        x = x0 + scale / 200.0 * np.array( [-81, -79, np.nan, -71, -69] )
        y = y0 + scale / 200.0 * np.array( [-60, -40, np.nan, 40, 60] )
        z = z0 * np.ones_like( x )
        h = mlab.plot3d( x, y, z, color=color, line_width=line_width, tube_radius=None, **kwargs )
        self.colon = h
        fig.scene.disable_render = render
        return
    def __call__( self, time=None ):
        from enthought.mayavi import mlab
        fig = mlab.gcf()
        render = fig.scene.disable_render
        fig.scene.disable_render = True
        self.colon.visible = False
        for hh in self.glyphs:
            for h in hh:
                h.visible = False
        if time is not None:
            self.colon.visible = True
            m = int( time / 60 )
            d = int( (time % 60) / 10 )
            s = int( time % 10 )
            self.glyphs[m][0].visible = True
            self.glyphs[d][1].visible = True
            self.glyphs[s][2].visible = True
        fig.scene.disable_render = render
        return

