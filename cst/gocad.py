"""
GOCAD data tools.

paulbourke.net/dataformats/gocad/gocad.pdf
"""

def header(buff, counter=0, casters=None):
    """
    GOCAD header reader
    """
    if casters is None:
        casters = {
            int: ('pclip', 'field'),
            bool: ('imap', 'ivolmap', 'parts', 'transparency'),
            float: ('contrast', 'low_clip', 'high_clip', 'transparency_min'),
        }
    cast = {}
    for c in casters:
        for k in casters[c]:
            cast[k] = c
    header = {}
    while counter < len(buff):
        line = buff[counter]
        counter += 1
        if '}' in line:
            return header, counter
        k, v = line.split(':')
        k = k.split('*')[-1]
        header[k] = v
        if k in cast:
            f = v.split()
            if len(f) > 1:
                try:
                    header[k] = tuple(cast[k](x) for x in f)
                except ValueError:
                    print('Warning: could not cast %s %s to %s' % (k, v, cast[k]))
            else:
                try:
                    header[k] = cast[k](v)
                except ValueError:
                    print('Warning: could not cast %s %s to %s' % (k, v, cast[k]))
    raise Exception('Error in header')
    return

def voxet(path, load_props=[], alternate='', no_data_value=None, buff=None):
    """
    GOCAD voxet reader
    """
    import os
    import numpy as np
    if buff == None:
        buff = open(path).read()
    buff = buff.strip().split('\n')
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
    while counter < len(buff):
        line = buff[counter].strip()
        counter += 1
        f = line.replace('"', '').split()
        if len(f) == 0 or line.startswith('#'):
            continue
        elif line.startswith('GOCAD Voxet'):
            id_ = f[2]
            axis, prop = {}, {}
        elif f[0] == 'HEADER':
            hdr, counter = header(buff, counter)
        elif len(f) > 1:
            k = f[0].split('_', 1)
            if k[0] == 'AXIS':
                axis[k[1]] = tuple(cast[k[1]](x) for x in f[1:])
            elif f[0] == 'PROPERTY':
                prop[f[1]] = {'PROPERTY': f[2]}
            elif k[0] == 'PROP':
                if len(f) > 3:
                    prop[f[1]][k[1]] = tuple(cast[k[1]](x) for x in f[2:])
                else:
                    prop[f[1]][k[1]] = cast[k[1]](f[2])
        elif f[0] == 'END':
            for p in load_props:
                p = prop[p]
                n = axis['N']
                f = os.path.join(os.path.dirname(path), p['FILE'] + alternate)
                if os.path.exists(f):
                    dtype = '>f%s' % p['ESIZE']
                    data = np.fromfile(f, dtype)
                    if no_data_value in ('nan', 'NaN', 'NAN'):
                        data[data==p['NO_DATA_VALUE']] = float('nan')
                    elif no_data_value is not None:
                        data[data==p['NO_DATA_VALUE']] = no_data_value
                    p['DATA'] = data.reshape(n[::-1]).T
            voxet[id_] = {'HEADER': hdr, 'AXIS': axis, 'PROP': prop}
    return voxet

def tsurf(buff):
    """
    GOCAD triangulated surface reader
    """
    import numpy as np
    buff = buff.strip().split('\n')
    tsurf = []
    counter = 0
    #casters = {
    #    int: ('ATOM', 'PATOM', 'TRGL', 'BORDER', 'BSTONE'),
    #    float: ('VRTX', 'PVRTX'),
    #}
    while counter < len(buff):
        line = buff[counter].strip()
        counter += 1
        f = line.split()
        if len(f) == 0 or line.startswith('#'):
            continue
        elif line.startswith('GOCAD TSurf'):
            meta0, meta, tri, x, t, b, s = None, {}, [], [], [], [], []
        elif f[0] in ('VRTX', 'PVRTX'):
            x.append([float(f[2]), float(f[3]), float(f[4])])
        elif f[0] in ('ATOM', 'PATOM'):
            i = int(f[2]) - 1
            x.append(x[i])
        elif f[0] == 'TRGL':
            t.append([int(f[1]) - 1, int(f[2]) - 1, int(f[3]) - 1])
        elif f[0] == 'BORDER':
            b.append([int(f[2]) - 1, int(f[3]) - 1])
        elif f[0] == 'BSTONE':
            s.append(int(f[1]) - 1)
        elif f[0] == 'TFACE':
            if t != []:
                tri.append(np.array(t, 'i'))
            t = []
        elif f[0] == 'END':
            tri.append(np.array(t, 'i'))
            x = np.array(x, 'f')
            b = np.array(b, 'i')
            s = np.array(s, 'i')
            data = {'vtx': x, 'tri': tri, 'border': b, 'bstone': s}
            meta.update(meta0)
            tsurf.append([meta, data])
        elif f[0] == 'PROPERTY_CLASS_HEADER':
            meta[f[1]], counter = header(buff, counter)
        elif f[0] == 'HEADER':
            meta0, counter = header(buff, counter)
    return tsurf

