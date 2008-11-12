#!/usr/bin/env python
"""
Field variable information

A table of the multi-dimensional field variable names that can be used for
input and output.  Flags in the last column indicate the following properties:
    <: Input field. Default is output only.
    0: Non-time varying field, accessible at initialization only.
    c: Cell-valued field (default is node-valued field)
    f: 2D fault variable (default is 3D volume variable)
Note: For efficiency, magnitudes of 3D fields (am2, vm2, um2, wm2) are
magnitude squared because square roots are computationally expensive.  Also,
stress magnitude (wm2) is the square of the Frobenius Norm, as finding the true
stress tensor magnitude requires computing eigenvalues at every location.
"""

table = [
    ( 'x1',    'X',            'Node coordinate',                '<0',  ),
    ( 'x2',    'Y',            'Node coordinate',                '<0',  ),
    ( 'x3',    'Z',            'Node coordinate',                '<0',  ),
    ( 'X1',    'X',            'Cell coordinate',                'c0',  ),
    ( 'X2',    'Y',            'Cell coordinate',                'c0',  ),
    ( 'X3',    'Z',            'Cell coordinate',                'c0',  ),
    ( 'rho',   '\rho',         'Density',                        '<c0', ),
    ( 'vp',    'V_p',          'P-wave velocity',                '<c0', ),
    ( 'vs',    'V_s',          'S-wave velocity',                '<c0', ),
    ( 'gam',   '\gamma',       'Viscosity',                      '<c0', ),
    ( 'mu',    '\mu',          'Elastic modulus',                'c0',  ),
    ( 'lam',   '\lambda',      'Elastic modulus',                'c0',  ),
    ( 'f1',    'F_x',          'Force',                          '<',   ),
    ( 'f2',    'F_y',          'Force',                          '<',   ),
    ( 'f3',    'F_z',          'Force',                          '<',   ),
    ( 'a1',    'A_x',          'Acceleration',                   '<',   ),
    ( 'a2',    'A_y',          'Acceleration',                   '<',   ),
    ( 'a3',    'A_z',          'Acceleration',                   '<',   ),
    ( 'am2',   '|A|',          'Acceleration magnitude',         '',    ),
    ( 'v1',    'V_x',          'Velocity',                       '<',   ),
    ( 'v2',    'V_y',          'Velocity',                       '<',   ),
    ( 'v3',    'V_z',          'Velocity',                       '<',   ),
    ( 'vm2',   '|V|',          'Velocity magnitude',             '',    ),
    ( 'u1',    'U_x',          'Displacement',                   '<',   ),
    ( 'u2',    'U_y',          'Displacement',                   '<',   ),
    ( 'u3',    'U_z',          'Displacement',                   '<',   ),
    ( 'um2',   '|U|',          'Displacement magnitude',         '',    ),
    ( 'exx',   'W_{xx}',       'Strain',                         '<c',  ),
    ( 'eyy',   'W_{yy}',       'Strain',                         '<c',  ),
    ( 'ezz',   'W_{zz}',       'Strain',                         '<c',  ),
    ( 'eyz',   'W_{yz}',       'Strain',                         '<c',  ),
    ( 'ezx',   'W_{zx}',       'Strain',                         '<c',  ),
    ( 'exy',   'W_{xy}',       'Strain',                         '<c',  ),
    ( 'wxx',   'W_{xx}',       'Stress',                         '<c',  ),
    ( 'wyy',   'W_{yy}',       'Stress',                         '<c',  ),
    ( 'wzz',   'W_{zz}',       'Stress',                         '<c',  ),
    ( 'wyz',   'W_{yz}',       'Stress',                         '<c',  ),
    ( 'wzx',   'W_{zx}',       'Stress',                         '<c',  ),
    ( 'wxy',   'W_{xy}',       'Stress',                         '<c',  ),
    ( 'wm2',   '|W|',          'Stress Frobenius norm',          'c',   ),
    ( 'mus',   '\mu_s',        'Static friction coefficient',    '<f0', ),
    ( 'mud',   '\mu_d',        'Dynamic friction coefficient',   '<f0', ),
    ( 'dc',    'D_c',          'Slip weakening distance',        '<f0', ),
    ( 'co',    'co',           'Cohesion',                       '<f0', ),
    ( 'sxx',   '\sigma_{xx}',  'Pre-stress',                     '<f0', ),
    ( 'syy',   '\sigma_{yy}',  'Pre-stress',                     '<f0', ),
    ( 'szz',   '\sigma_{zz}',  'Pre-stress',                     '<f0', ),
    ( 'syz',   '\sigma_{yz}',  'Pre-stress',                     '<f0', ),
    ( 'szx',   '\sigma_{zx}',  'Pre-stress',                     '<f0', ),
    ( 'sxy',   '\sigma_{xy}',  'Pre-stress',                     '<f0', ),
    ( 'tn',    'T_n',          'Pre-traction, normal component', '<f0', ),
    ( 'ts',    'T_s',          'Pre-traction, strike component', '<f0', ),
    ( 'td',    'T_d',          'Pre-traction, dip component',    '<f0', ),
    ( 'nhat1', 'n_x',          'Fault surface normal',           'f0',  ),
    ( 'nhat2', 'n_y',          'Fault surface normal',           'f0',  ),
    ( 'nhat3', 'n_z',          'Fault surface normal',           'f0',  ),
    ( 't1',    'T_x',          'Traction',                       'f',   ),
    ( 't2',    'T_y',          'Traction',                       'f',   ),
    ( 't3',    'T_z',          'Traction',                       'f',   ),
    ( 'ts1',   'T_s_x',        'Shear traction',                 'f',   ),
    ( 'ts2',   'T_s_y',        'Shear traction',                 'f',   ),
    ( 'ts3',   'T_s_z',        'Shear traction',                 'f',   ),
    ( 'tsm',   '|T_s|',        'Shear traction magnitude',       'f',   ),
    ( 'tnm',   'T_n',          'Normal traction',                'f',   ),
    ( 'fr',    'f',            'Friction',                       'f',   ),
    ( 'sa1',   'A_s_x',        'Slip acceleration',              'f',   ),
    ( 'sa2',   'A_s_y',        'Slip acceleration',              'f',   ),
    ( 'sa3',   'A_s_z',        'Slip acceleration',              'f',   ),
    ( 'sam',   '|A_s|',        'Slip acceleration magnitude',    'f',   ),
    ( 'sv1',   'V_s_x',        'Slip velocity',                  'f',   ),
    ( 'sv2',   'V_s_y',        'Slip velocity',                  'f',   ),
    ( 'sv3',   'V_s_z',        'Slip velocity',                  'f',   ),
    ( 'svm',   '|V_s|',        'Slip velocity magnitude',        'f',   ),
    ( 'psv',   '|V_s|_{peak}', 'Peak slip velocity',             'f',   ),
    ( 'su1',   'U_s_x',        'Slip',                           'f',   ),
    ( 'su2',   'U_s_y',        'Slip',                           'f',   ),
    ( 'su3',   'U_s_z',        'Slip',                           'f',   ),
    ( 'sum',   '|V_s|',        'Slip magnitude',                 'f',   ),
    ( 'sl',    'l',            'Slip path length',               'f',   ),
    ( 'trup',  't_{rupture}',  'Rupture time',                   'f',   ),
    ( 'tarr',  't_{arrest}',   'Arrest time',                    'f',   ),
]

map     = dict( [ ( f[0], f[1:0] ) for f in table ] )
all     = [ f[0] for f in table ]
input   = [ f[0] for f in table if '<' in f[-1] ]
initial = [ f[0] for f in table if '0' in f[-1] ]
cell    = [ f[0] for f in table if 'c' in f[-1] ]
fault   = [ f[0] for f in table if 'f' in f[-1] ]
volume  = [ f[0] for f in table if 'f' not in f[-1] ]

if __name__ == '__main__':
    for i in range( len( all ) ):
        if all[i] in all[:i]:
            print 'Error: duplicate field: %r' % all[i]
