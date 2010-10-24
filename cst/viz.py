"""
Visualization utilities
"""
import subprocess, cStringIO
import numpy as np

def distill_eps( fd, mode=None ):
    """
    Distill EPS to PDF using Ghostscript.
    """
    if type( fd ) == str:
        fd = cStringIO.StringIO( fd )
    cmd = 'ps2pdf', '-dEPSCrop', '-dPDFSETTINGS=/prepress', '-', '-'
    pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
    fd = pid.communicate( fd.getvalue() )[0]
    if mode != 'str':
        fd = cStringIO.StringIO( fd )
        fd.reset()
    return( fd )

def pdf2png( path, dpi=72, mode=None ):
    """
    Rasterize a PDF file using Ghostscript.
    """
    cmd = 'gs', '-q', '-r%s' % dpi, '-dNOPAUSE', '-dBATCH', '-sDEVICE=pngalpha', '-sOutputFile=-', path
    pid = subprocess.Popen( cmd, stdout=subprocess.PIPE )
    out = pid.communicate()[0]
    if mode != 'str':
        out = cStringIO.StringIO( out )
        out.reset()
    return( out )

def img2pdf( img, dpi=150, mode=None ):
    """
    Convert image array to PDF using PIL and ImageMagick.
    """
    import Image
    fd = cStringIO.StringIO()
    img = Image.fromarray( img )
    img.save( fd, format='png' )
    cmd = 'convert', '-density', str( dpi ), 'png:-', 'pdf:-'
    pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
    fd = pid.communicate( fd.getvalue() )[0]
    if mode != 'str':
        fd = cStringIO.StringIO( fd )
        fd.reset()
    return( fd )

def pdf_merge( layers ):
    """
    Overlay multiple single page PDF file descriptors.
    """
    import pyPdf
    out = cStringIO.StringIO()
    pdf = pyPdf.PdfFileWriter()
    page = pyPdf.PdfFileReader( layers[0] )
    page = page.getPage( 0 )
    for i in layers[1:]:
        i = pyPdf.PdfFileReader( i )
        i = i.getPage( 0 )
        page.mergePage( i )
    pdf.addPage( page )
    pdf.write( out )
    out.reset()
    return( out )

def colormap( cmap, colorexp=1.0, nmod=0, modlim=0.5, upsample=True, invert=False ):
    """
    Color map creator.

    Parameters
    ----------
        cmap: Either a named colormap from viz.colormap_library or a 5 x N array,
            with rows specifying: (value, red, green, blue, alpha) components.
        colorexp: Exponent applied to the values to shift the colormap.
        nmod: Number of brightness modulations applied to the colormap.
        modlim: Magnitude of brightness modulations.
        upsample: Increase the number of samples if non-linear map (colorexp != 1)
        invert: Intert the order of colors.
    """
    if type( cmap ) is str:
        cmap = colormap_library[cmap]
    cmap = np.array( cmap, 'f' )
    if invert:
        cmap = cmap[:,::-1]
    cmap[1:] /= max( 1.0, cmap[1:].max() )
    v, r, g, b, a = cmap
    v /= v[-1]
    if upsample and colorexp != 1.0:
        n = 16
        x  = np.linspace( 0.0, 1.0, len(v) )
        xi = np.linspace( 0.0, 1.0, (len(v) - 1) * n + 1 )
        r = np.interp( xi, x, r )
        g = np.interp( xi, x, g )
        b = np.interp( xi, x, b )
        a = np.interp( xi, x, a )
        v = np.interp( xi, x, v )
        v = np.sign( v ) * abs( v ) ** colorexp
    v = (v - v[0]) / (v[-1] - v[0])
    if nmod > 0:
        if len( v ) < 6 * nmod:
            vi = np.linspace( v[0], v[-1], 8 * nmod + 1 )
            r = np.interp( vi, v, r )
            g = np.interp( vi, v, g )
            b = np.interp( vi, v, b )
            a = np.interp( vi, v, a )
            v = vi
        w1 = np.cos( np.pi * 2.0 * nmod * v ) * modlim
        w1 = 1.0 - np.maximum( w1, 0.0 )
        w2 = 1.0 + np.minimum( w1, 0.0 )
        r = ( 1.0 - w2 * (1.0 - w1 * r) )
        g = ( 1.0 - w2 * (1.0 - w1 * g) )
        b = ( 1.0 - w2 * (1.0 - w1 * b) )
        a = ( 1.0 - w2 * (1.0 - w1 * a) )
    return np.array( [v, r, g, b, a] )

def cpt( *args, **kwargs ):
    """
    GMT style colormap. See viz.colormap for details.
    """
    v, r, g, b, a = colormap( *args, **kwargs )
    cmap = ''
    fmt = '%-10r %3.0f %3.0f %3.0f     %-10r %3.0f %3.0f %3.0f\n'
    for i in range( len( v ) - 1 ):
        cmap += fmt % (
            v[i],   255 * r[i],   255 * g[i],   255 * b[i],
            v[i+1], 255 * r[i+1], 255 * g[i+1], 255 * b[i+1],
        )
    return cmap

colormap_library = {
    'wwwwbgr': [
        (0, 4, 5, 7, 8, 9, 11, 12),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wwwbgr': [
        (0, 2, 3, 5, 6, 7, 9, 10),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wwbgr': [
        (0, 1, 2, 4, 5, 6, 8, 9),
        (2, 2, 0, 0, 0, 2, 2, 2),
        (2, 2, 1, 2, 2, 2, 1, 0),
        (2, 2, 2, 2, 0, 0, 0, 0),
        (2, 2, 2, 2, 2, 2, 2, 2),
    ],
    'wbgr': [
        (0,  1,  3,  4,  5,  7,  8),
        (2,  0,  0,  0,  2,  2,  2),
        (2,  1,  2,  2,  2,  1,  0),
        (2,  2,  2,  0,  0,  0,  0),
        (2,  2,  2,  2,  2,  2,  2),
    ],
    'wrgb': [
        (0,  1,  3,  4,  5,  7,  8),
        (2,  2,  2,  0,  0,  0,  0),
        (2,  1,  2,  2,  2,  1,  0),
        (2,  0,  0,  0,  2,  2,  2),
        (2,  2,  2,  2,  2,  2,  2),
    ],
    'bgr': [
        (0,  1,  3,  4,  5,  7,  8),
        (0,  0,  0,  0,  2,  2,  2),
        (0,  1,  2,  2,  2,  1,  0),
        (2,  2,  2,  0,  0,  0,  0),
        (2,  2,  2,  2,  2,  2,  2),
    ],
    'rgb': [
        (0,  1,  3,  4,  5,  7,  8),
        (2,  2,  2,  0,  0,  0,  0),
        (0,  1,  2,  2,  2,  1,  0),
        (0,  0,  0,  0,  2,  2,  2),
        (2,  2,  2,  2,  2,  2,  2),
    ],
    'bwr': [
        (-4, -3, -1,  0,  1,  3,  4),
        ( 0,  0,  0,  2,  2,  2,  1),
        ( 0,  0,  2,  2,  2,  0,  0),
        ( 1,  2,  2,  2,  0,  0,  0),
        ( 2,  2,  2,  2,  2,  2,  2),
    ],
    'cwy': [
        (-2, -1,  0,  1,  2),
        ( 0,  0,  1,  1,  1),
        ( 1,  0,  1,  0,  1),
        ( 1,  1,  1,  0,  0),
        ( 1,  1,  1,  1,  1),
    ],
}

