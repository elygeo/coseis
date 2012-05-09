#!/usr/bin/env python
import cst                                  # import the Coseis module
prm = cst.sord.parameters()                 # for specifying SORD parameters
s_ = cst.sord.s_                            # for specifying slices
prm.delta = 100.0, 100.0, 100.0, 0.0075     # step length in (x, y, z, t)
prm.shape = 61, 61, 61, 60                  # mesh size in (x, y, z, t)
prm.fieldio = [                             # field variable input and output
    ('=',  'rho', [], 2670.0),              # material density
    ('=',  'vp',  [], 6000.0),              # material P-wave velocity
    ('=',  'vs',  [], 3464.0),              # material S-wave velocity
    ('=',  'gam', [], 0.3),                 # material viscosity
    ('=w', 'v1',  s_[:,:,31,-1], 'vx.bin'), # write X velocity slice output
    ('=w', 'v2',  s_[:,:,31,-1], 'vy.bin'), # write Y velocity slice output
]
prm.ihypo = 31.0, 31.0, 31.0                # source location
prm.source = 'potency'                      # source type
prm.source1 = 1e6, 1e6, 1e6                 # source normal components
prm.source2 = 0.0, 0.0, 0.0                 # source shear components
prm.pulse = 'integral_brune'                # source time function
prm.tau = 6 * prm.delta[3]                  # source characteristic time
cst.sord.run(prm)                           # launch SORD job
