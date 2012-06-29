"""
CVMS Configuration
"""
name = 'cvms'
code = 'cvms'
version = '4.0'
minutes = 20
stagein = ['hold/']

build_fflags = '-O3 -Wall'
build_cvms = {
   'alcf_bg': '-O3 -qfixed -qsuppress=cmpmsg',
   'tacc_ranger': '-O3 -warn -std08',
   'nics_kraken': '-fast -Mdclchk',
}

nsample = 0
file_lon = 'hold/lon.bin'
file_lat = 'hold/lat.bin'
file_dep = 'hold/dep.bin'
file_rho = 'hold/rho.bin'
file_vp = 'hold/vp.bin'
file_vs = 'hold/vs.bin'

