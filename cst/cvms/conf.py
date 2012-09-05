"""
CVMS Configuration
"""
name = 'cvms'
code = 'cvms'
version = '4.0'
minutes = 20

build_fflags = '-O3 -Wall'
build_cvms = {
   'alcf_bg': '-O3 -qfixed -qsuppress=cmpmsg',
   'tacc_ranger': '-O3 -warn -std08',
   'nics_kraken': '-fast',
}

nsample = 0
file_lon = 'lon.bin'
file_lat = 'lat.bin'
file_dep = 'dep.bin'
file_rho = 'rho.bin'
file_vp = 'vp.bin'
file_vs = 'vs.bin'

