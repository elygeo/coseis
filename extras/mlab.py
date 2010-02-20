#!/usr/bin/env python
"""
Mayavi utilities
"""
import numpy

def text3d( x, y, z, s, bcolor=None, bwidth=0.5, bn=16, **kwargs ):
    """
    Mayavi text3d command augmented with poor man's bold.
    """
    from enthought.mayavi import mlab
    h = []
    if bcolor != None:
        args = kwargs.copy()
        args['color'] = bcolor
        for i in range( bn ):
            phi = 2.0 * numpy.pi * i / bn
            x_ = x + bwidth * numpy.cos( phi )
            y_ = y + bwidth * numpy.sin( phi )
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
    fig.scene.render()
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
    def __init__( self, x0=0, y0=0, z0=0, scale=1.0, color=(0,1,0), line_width=3 ):
        from enthought.mayavi import mlab
        fig = mlab.gcf()
        render = fig.scene.disable_render
        fig.scene.disable_render = True
        xx = x0 + scale / 200.0 * numpy.array( [
            [  -49,  -40, numpy.nan ],
            [   51,   60, numpy.nan ],
            [  -60,  -51, numpy.nan ],
            [   40,   49, numpy.nan ],
            [  -30,   50, numpy.nan ],
            [  -40,   40, numpy.nan ],
            [  -50,   30, numpy.nan ],
        ] )
        yy = y0 + scale / 200.0 * numpy.array( [
            [   10,   90, numpy.nan ],
            [   10,   90, numpy.nan ],
            [  -90,  -10, numpy.nan ],
            [  -90,  -10, numpy.nan ],
            [  100,  100, numpy.nan ],
            [    0,    0, numpy.nan ],
            [ -100, -100, numpy.nan ],
        ] )
        zz = z0 * numpy.ones_like( xx )
        glyphs = [5], [0,2,4,5,6], [0,3], [0,2], [2,4,6], [1,2], [1], [0,2,5,6], [], [2]
        hh = []
        for g in glyphs:
            i = numpy.array( [ i for i in range(7) if i not in g ] )
            h = []
            for x in -0.875, 0.125, 0.875:
                h += [ mlab.plot3d(
                    scale * x + xx[i].flatten(), yy[i].flatten(), zz[i].flatten(),
                    color=color,
                    tube_radius=None,
                    line_width=line_width,
                ) ]
            hh += [h]
        self.glyphs = hh
        x = x0 + scale / 200.0 * numpy.array( [-81, -79, numpy.nan, -71, -69] )
        y = y0 + scale / 200.0 * numpy.array( [-60, -40, numpy.nan, 40, 60] )
        z = z0 * numpy.ones_like( x )
        h = mlab.plot3d( x, y, z, color=color, tube_radius=None, line_width=line_width )
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
        if time != None:
            self.colon.visible = True
            m = int( time / 60 )
            d = int( (time % 60) / 10 )
            s = int( time % 10 )
            self.glyphs[m][0].visible = True
            self.glyphs[d][1].visible = True
            self.glyphs[s][2].visible = True
        fig.scene.disable_render = render
        return

