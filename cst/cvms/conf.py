nsample = None
version = '4.0'
file_lon = 'hold/lon.bin'
file_lat = 'hold/lat.bin'
file_dep = 'hold/dep.bin'
file_rho = 'hold/rho.bin'
file_vp = 'hold/vp.bin'
file_vs = 'hold/vs.bin'

minutes = 20
stagein = ['hold/']
build_fc = 'xlf2003_r -O3 -qfixed -qsuppress=cmpmsg'
build_fc = 'gfortran -O3 -Wall'
build_fc = 'ifort -O3 -warn -std08'

