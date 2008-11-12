notes = """
SDSU Altai
Sun-Fire-880
"""
login = 'altai.sdsu.edu'
hosts = [ 'altai' ]
nodes = 1
cores = 8
ram = 30000
sfc = [ 'f95' ]
mfc = [ 'mpif90' ]
_ = [ '-u', '-o' ]
g = [ '-w4', '-C', '-g' ] + _
p = [ '-O', '-p' ] + _
O = [ '-fast' ] + _
