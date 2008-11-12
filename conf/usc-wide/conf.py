notes = """
USC Wide
MacBook Pro
Intel Core 2 Duo 2.6GHz
4GB
"""
login = 'wide.usc.edu'
hosts = [ 'wide' ]
nodes = 1
cores = 2
ram = 3800
sfc = [ 'gfortran' ]
mfc = [ 'mpif90', '-mpe=mpilog' ]
mfc = [ 'mpif90' ]
_ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
_ = [ '-fimplicit-none', '-Wall', '-std=f95', '-o' ]
_ = [ '-fimplicit-none', '-Wall', '-o' ]
g = [ '-g', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
p = [ '-O', '-pg' ] + _
O = [ '-O3' ] + _

