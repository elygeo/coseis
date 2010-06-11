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
    ( 'x1',    'x',               'Node coordinate',                '<0',  ),
    ( 'x2',    'y',               'Node coordinate',                '<0',  ),
    ( 'x3',    'z',               'Node coordinate',                '<0',  ),
    ( 'c1',    'x',               'Cell coordinate',                'c0',  ),
    ( 'c2',    'y',               'Cell coordinate',                'c0',  ),
    ( 'c3',    'z',               'Cell coordinate',                'c0',  ),
    ( 'rho',   '\rho',            'Density',                        '<c0', ),
    ( 'vp',    'V_p',             'P-wave velocity',                '<c0', ),
    ( 'vs',    'V_s',             'S-wave velocity',                '<c0', ),
    ( 'gam',   '\gamma',          'Viscosity',                      '<c0', ),
    ( 'vc',    'V^C',             'Cell volume',                    'c0',  ),
    ( 'mu',    '\mu',             'Elastic modulus',                'c0',  ),
    ( 'lam',   '\lambda',         'Elastic modulus',                'c0',  ),
    ( 'f1',    'f_x',             'Force',                          '<',   ),
    ( 'f2',    'f_y',             'Force',                          '<',   ),
    ( 'f3',    'f_z',             'Force',                          '<',   ),
    ( 'a1',    'a_x',             'Acceleration',                   '<',   ),
    ( 'a2',    'a_y',             'Acceleration',                   '<',   ),
    ( 'a3',    'a_z',             'Acceleration',                   '<',   ),
    ( 'am2',   '|a|',             'Acceleration magnitude',         '',    ),
    ( 'v1',    'v_x',             'Velocity',                       '<',   ),
    ( 'v2',    'v_y',             'Velocity',                       '<',   ),
    ( 'v3',    'v_z',             'Velocity',                       '<',   ),
    ( 'vm2',   '|v|',             'Velocity magnitude',             '',    ),
    ( 'u1',    'u_x',             'Displacement',                   '<',   ),
    ( 'u2',    'u_y',             'Displacement',                   '<',   ),
    ( 'u3',    'u_z',             'Displacement',                   '<',   ),
    ( 'um2',   '|u|',             'Displacement magnitude',         '',    ),
    ( 'e11',   'e_{xx}',          'Strain',                         '<c',  ),
    ( 'e22',   'e_{yy}',          'Strain',                         '<c',  ),
    ( 'e33',   'e_{zz}',          'Strain',                         '<c',  ),
    ( 'e23',   'e_{yz}',          'Strain',                         '<c',  ),
    ( 'e31',   'e_{zx}',          'Strain',                         '<c',  ),
    ( 'e12',   'e_{xy}',          'Strain',                         '<c',  ),
    ( 'w11',   '\sigma_{xx}',     'Stress',                         '<c',  ),
    ( 'w22',   '\sigma_{yy}',     'Stress',                         '<c',  ),
    ( 'w33',   '\sigma_{zz}',     'Stress',                         '<c',  ),
    ( 'w23',   '\sigma_{yz}',     'Stress',                         '<c',  ),
    ( 'w31',   '\sigma_{zx}',     'Stress',                         '<c',  ),
    ( 'w12',   '\sigma_{xy}',     'Stress',                         '<c',  ),
    ( 'wm2',   '||\sigma||_F',    'Stress Frobenius norm',          'c',   ),
    # slip weakening variables
    ( 'mus',   '\mu_s',           'Static friction coefficient',    '<f0', ),
    ( 'mud',   '\mu_d',           'Dynamic friction coefficient',   '<f0', ),
    ( 'dc',    'D_c',             'Slip weakening distance',        '<f0', ),
    ( 'co',    'co',              'Cohesion',                       '<f0', ),
    ( 's11',   '\sigma_{xx}',     'Pre-stress',                     '<f0', ),
    ( 's22',   '\sigma_{yy}',     'Pre-stress',                     '<f0', ),
    ( 's33',   '\sigma_{zz}',     'Pre-stress',                     '<f0', ),
    ( 's23',   '\sigma_{yz}',     'Pre-stress',                     '<f0', ),
    ( 's31',   '\sigma_{zx}',     'Pre-stress',                     '<f0', ),
    ( 's12',   '\sigma_{xy}',     'Pre-stress',                     '<f0', ),
    ( 'tn',    '\tau_n',          'Pre-traction, normal component', '<f0', ),
    ( 'ts',    '\tau_s',          'Pre-traction, strike component', '<f0', ),
    ( 'td',    '\tau_d',          'Pre-traction, dip component',    '<f0', ),
    ( 'nhat1', 'n_x',             'Fault surface normal',           'f0',  ),
    ( 'nhat2', 'n_y',             'Fault surface normal',           'f0',  ),
    ( 'nhat3', 'n_z',             'Fault surface normal',           'f0',  ),
    ( 't1',    '\tau_x',          'Traction',                       'f',   ),
    ( 't2',    '\tau_y',          'Traction',                       'f',   ),
    ( 't3',    '\tau_z',          'Traction',                       'f',   ),
    ( 'ts1',   '\tau^s_x',        'Shear traction',                 'f',   ),
    ( 'ts2',   '\tau^s_y',        'Shear traction',                 'f',   ),
    ( 'ts3',   '\tau^s_z',        'Shear traction',                 'f',   ),
    ( 'tnm',   '\tau^n',          'Normal traction',                'f',   ),
    ( 'tsm',   '|\tau^s|',        'Shear traction magnitude',       'f',   ),
    ( 'fr',    '\tau_c',          'Friction',                       'f',   ),
    ( 'sa1',   '\ddot s_x',       'Slip acceleration',              'f',   ),
    ( 'sa2',   '\ddot s_y',       'Slip acceleration',              'f',   ),
    ( 'sa3',   '\ddot s_z',       'Slip acceleration',              'f',   ),
    ( 'sam',   '|\ddot s|',       'Slip acceleration magnitude',    'f',   ),
    ( 'sv1',   '\dot s_x',        'Slip velocity',                  'f',   ),
    ( 'sv2',   '\dot s_y',        'Slip velocity',                  'f',   ),
    ( 'sv3',   '\dot s_z',        'Slip velocity',                  'f',   ),
    ( 'svm',   '|\dot s|',        'Slip velocity magnitude',        'f',   ),
    ( 'psv',   '|\dot s|_{peak}', 'Peak slip velocity',             'f',   ),
    ( 'su1',   's_x',             'Slip',                           'f',   ),
    ( 'su2',   's_y',             'Slip',                           'f',   ),
    ( 'su3',   's_z',             'Slip',                           'f',   ),
    ( 'sum',   '|s|',             'Slip magnitude',                 'f',   ),
    ( 'sl',    '\ell',            'Slip path length',               'f',   ),
    ( 'trup',  't_{rupture}',     'Rupture time',                   'f',   ),
    ( 'tarr',  't_{arrest}',      'Arrest time',                    'f',   ),
    # rate and state friction variables [ZS]
    #( 'f0',    'f_0',             'Steady state friction at V_0',   '<f0', ),
    #( 'fw',    'f_w',             'Fully weakened fiction',         '<f0', ),
    #( 'v0',    'V_0',             'Reference slip velocity',        '<f0', ),
    #( 'vw',    'V_w',             'Weakening slip velocity',        '<f0', ),
    #( 'll',    'L',               'State evolution distance',       '<f0', ),
    #( 'af',    'a',               'Direct effect parameter',        '<f0', ),
    #( 'bf',    'b',               'Evolution effect parameter',     '<f0', ),
    #( 'psi',   '\psi',            'State variable',                 'f',   ),
]

map     = dict( (f[0], f[1:]) for f in table )
all     = [ f[0] for f in table ]
input   = [ f[0] for f in table if '<' in f[-1] ]
initial = [ f[0] for f in table if '0' in f[-1] ]
cell    = [ f[0] for f in table if 'c' in f[-1] ]
fault   = [ f[0] for f in table if 'f' in f[-1] ]
volume  = [ f[0] for f in table if 'f' not in f[-1] ]

# If run from the command line, check for duplicates.
if __name__ == '__main__':
    for i in range( len( all ) ):
        if all[i] in all[:i]:
            print( 'Error: duplicate field: %r' % all[i] )

