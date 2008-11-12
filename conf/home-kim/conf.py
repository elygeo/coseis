notes = """
Kim
MacBook
"""
login = 'kim'
hosts = [ login ]
nodes = 1
cores = 2
ram = 800
sfc = [ 'gfortran' ]
mfc = [ 'mpif90', '-mpe=mpilog' ]
mfc = [ 'mpif90' ]
_ = [ '-fimplicit-none', '-Wall', '-o' ]
_ = [ '-fimplicit-none', '-Wall', '-std=f95', '-pedantic', '-o' ]
g = [ '-g', '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
p = [ '-O', '-p' ] + _
O = [ '-O3' ] + _

