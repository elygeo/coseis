notes = """
USC Wind

Intel(R) Pentium(R) 4 CPU 3.20GHz
1GB
"""
login = 'phim.usc.edu'
hosts = [ login ]
nodes = 1
cores = 2
rate = 1.0e6
ram = 800
_ = [ '-fimplicit-none', '-Wall', '-o' ]
g = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow', '-g' ] + _
t = [ '-fbounds-check', '-ffpe-trap=invalid,zero,overflow' ] + _
p = [ '-O', '-pg' ] + _
O = [ '-O3' ] + _

