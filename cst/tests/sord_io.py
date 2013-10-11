#!/usr/bin/env python

def test(argv=[]):
    """
    Test SORD parallelization with point source
    """
    import os
    import numpy as np
    import cst
    prm = {}

    # parameters
    prm['argv'] = argv
    prm['itstats'] = 1
    prm['faultnormal'] = 1
    prm['shape'] = [6, 7, 8, 9]

    # output
    fld = cst.sord.fieldnames()
    x1 = [1.1, 1.1, 1.1]
    x2 = [9.9, 9.9, 9.9]
    ii = [4.4, 5.5, 6.6, 1]
    infiles = []
    for k in fld['dict']:
        prm[k] = []
    for k in 'a1', 'w11':
        prm[k] += [([], '#')]
        for op in ['=', '+', '*', '=~', '+~', '*~']:
            prm[k] += [([], op, 2.2)]
        for op in ['=@', '+@', '*@']:
            prm[k] += [([], op, x1, x2, 2.2)]
        for func in cst.sord.tfuncs:
            prm[k] += [([], '=', 2.2, func, 3.3)]
        prm[k] += [(ii, '.', 2.2)]
        for i, op in enumerate(['.<', '=<', '+<', '*<']):
            f = 'io/%s_i%s.bin' % (k, i)
            infiles.append(f)
            prm[k] += [(ii, op, f)]
    for k in fld['dict']:
        ii = [4.4, 5.5, 6.6, 1]
        if k in fld['initial']:
            ii = ii[:3]
        prm[k] += [
            (ii, '.>', 'io/%s_o1.bin' % k),
            (ii, '=>', 'io/%s_o0.bin' % k),
        ]

    prm['rundir'] = d = os.path.join('run', 'sord_io') + os.sep
    os.makedirs(d + 'io')
    for f in infiles:
        np.array([1.0], 'f').tofile(d + f)
    cst.sord.run(prm)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

