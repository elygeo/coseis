#!/usr/bin/env python
import os                                  # import O/S utilities
import cst                                 # import the Coseis module

prm = {                                    # dictionary of parameters
'rundir': 'run',                           # path to output files
'delta': [100.0, 100.0, 100.0, 0.0075],    # step length in (x, y, z, t)
'shape': [61, 61, 61, 60],                 # mesh size in (x, y, z, t)
'ihypo': [31.0, 31.0, 31.0],               # source location
'source1': [1e6, 1e6, 1e6],                # source normal components
'source2': [0.0, 0.0, 0.0],                # source shear components
'source': 'potency',                       # source type
'pulse': 'integral_brune',                 # source time function
'tau': 0.045,                              # source characteristic time
'fieldio': [                               # field variable input and output
    ['=', 'rho', [], 2670.0],              # material density
    ['=', 'vp',  [], 6000.0],              # material P-wave velocity
    ['=', 'vs',  [], 3464.0],              # material S-wave velocity
    ['=', 'gam', [], 0.3],                 # material viscosity
    ['=w', 'v1', [[],[],31,-1], 'vx.bin'], # write X velocity slice output
    ['=w', 'v2', [[],[],31,-1], 'vy.bin'], # write Y velocity slice output
],
}

os.mkdir('run')                            # create run directory
os.chdir('run')                            # switch to run directory
cst.sord.run(prm)                          # launch SORD code
