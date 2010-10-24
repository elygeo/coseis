"""
GOCAD (http://www.gocad.org) utilities
"""
import os, sys
import numpy as np

def header( lines, counter=0, casters=None ):
    """
    GOCAD header reader
    """
    if casters is None:
        casters = {
            int: ('pclip', 'field'),
            bool: ('imap', 'ivolmap', 'parts', 'transparency'),
            float: ('color', 'contrast', 'low_clip', 'high_clip', 'transparency_min'),
        }
    cast = {}
    for c in casters:
        for k in casters[c]:
            cast[k] = c
    header = {}
    while counter < len( lines ):
        line = lines[counter].strip()
        counter += 1
        if '}' in line:
            return header, counter
        k, v = line.split( ':' )
        k = k.split( '*' )[-1]
        if k not in cast:
            header[k] = v
        else:
            f = v.split()
            if len( f ) > 1:
                header[k] = tuple( cast[k]( x ) for x in f )
            else:
                header[k] = cast[k]( v )
    sys.exit( 'Error in header' )
    return

def voxet( path, load_prop=None, no_data_value='nan' ):
    """
    GOCAD voxet reader
    """
    lines = open( path ).readlines()
    cast = {}
    casters = {
        str: ('NAME', 'FILE', 'TYPE', 'ETYPE', 'FORMAT', 'UNIT', 'ORIGINAL_UNIT'),
        int: ('N', 'ESIZE', 'OFFSET', 'SIGNED', 'PAINTED_FLAG_BIT_POS'),
        float: ('O', 'D', 'U', 'V', 'W', 'MIN', 'MAX', 'NO_DATA_VALUE', 'SAMPLE_STATS'),
    }
    for c in casters:
        for k in casters[c]:
            cast[k] = c
    voxet = {}
    counter = 0
    while counter < len( lines ):
        line = lines[counter].strip()
        counter += 1
        f = line.replace('"', '').split()
        if len( f ) == 0 or line.startswith( '#' ):
            continue
        elif line.startswith( 'GOCAD Voxet' ):
            id_ = f[2]
            axis, prop = {}, {}
        elif f[0] == 'HEADER':
            hdr, counter = header( lines, counter )
        elif len( f ) > 1:
            k = f[0].split( '_', 1 )
            if k[0] == 'AXIS':
                axis[k[1]] = tuple( cast[k[1]]( x ) for x in f[1:] )
            elif f[0] == 'PROPERTY':
                prop[f[1]] = {'PROPERTY': f[2]}
            elif k[0] == 'PROP':
                if len( f ) > 3:
                    prop[f[1]][k[1]] = tuple( cast[k[1]]( x ) for x in f[2:] )
                else:
                    prop[f[1]][k[1]] = cast[k[1]]( f[2] )
        elif f[0] == 'END':
            if load_prop is not None:
                n = axis['N']
                p = prop[load_prop]
                f = os.path.join( os.path.dirname( path ), p['FILE'] )
                dtype = '>f%s' % p['ESIZE']
                data = np.fromfile( f, dtype )
                if no_data_value == 'nan':
                    data[data==p['NO_DATA_VALUE']] = np.nan
                elif no_data_value is not None:
                    data[data==p['NO_DATA_VALUE']] = no_data_value
                p['DATA'] = data.reshape( n[::-1] ).T
            voxet[id_] = {'HEADER': hdr, 'AXIS': axis, 'PROP': prop}
    return voxet

def tsurf( path ):
    """
    GOCAD triangulated surface reader
    """
    lines = open( path ).readlines()
    tsurf = []
    counter = 0
    #casters = {
    #    int: ('ATOM', 'PATOM', 'TRGL', 'BORDER', 'BSTONE'),
    #    float: ('VRTX', 'PVRTX'),
    #}
    while counter < len( lines ):
        line = lines[counter].strip()
        counter += 1
        f = line.split()
        if line.startswith( 'GOCAD TSurf' ):
            hdr, phdr, tface, vrtx, trgl, border, bstone = None, {}, [], [], [], [], []
        elif f[0] in ('VRTX', 'PVRTX'):
            vrtx += [[float(f[2]), float(f[3]), float(f[4])]]
        elif f[0] in ('ATOM', 'PATOM'):
            i = int( f[2] ) - 1
            vrtx += [ vrtx[i] ]
        elif f[0] == 'TRGL':
            trgl += [[int(f[1]) - 1, int(f[2]) - 1, int(f[3]) - 1]]
        elif f[0] == 'BORDER':
            border += [[int(f[2]) - 1, int(f[3]) - 1]]
        elif f[0] == 'BSTONE':
            bstone += [int(f[1]) - 1]
        elif f[0] == 'TFACE':
            if trgl != []:
                tface += [ np.array( trgl, 'i' ).T ]
            trgl = []
        elif f[0] == 'END':
            vrtx   = np.array( vrtx, 'f' ).T
            border = np.array( border, 'i' ).T
            bstone = np.array( bstone, 'i' ).T
            tface += [ np.array( trgl, 'i' ).T ]
            tsurf += [[hdr, phdr, vrtx, tface, border, bstone]]
        elif f[0] == 'PROPERTY_CLASS_HEADER':
            phdr[f[1]] = header( lines, counter )
        elif f[0] == 'HEADER':
            hdr = header( lines, counter )
    return tsurf

