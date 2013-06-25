"""
CVMS Configuration
"""

# parameters
version = '4.0'
nsample = 0
file_lon = 'lon.bin'
file_lat = 'lat.bin'
file_dep = 'dep.bin'
file_rho = 'rho.bin'
file_vp = 'vp.bin'
file_vs = 'vs.bin'

# configuration
max_samples = 4800000
nthread = 1
minutes = 60

# host specific configuration
host_opts_cvms = {
    'alcf_bgp': {
        'launch': 'cobalt-mpirun -mode vn -verbose 2 -np {nproc} {command}',
        'ppn_range': [1, 2, 4],
    },
    'alcf_bgq': {
        'launch': 'runjob --exe {command} -n {nproc} -p {ppn} --verbose=INFO --block $COBALT_PARTNAME ${{COBALT_CORNER:+--corner}} $COBALT_CORNER ${{COBALT_SHAPE:+--shape}} $COBALT_SHAPE --envs BG_SHAREDMEMSIZE=32MB PAMID_VERBOSE=1 VPROF_PROFILE=yes\n',
        'ppn_range': [1, 2, 4, 8, 16, 32],
    },
    'nics_kraken': {
        'launch': 'aprun -n {nproc} {command}',
        'ppn_range': [],
    },
}

