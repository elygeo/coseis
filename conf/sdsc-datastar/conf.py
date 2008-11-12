notes = """
SDSC DataStar - (retired)
"""
login = 'dslogin.sdsc.edu'
hosts = [ login ]
nodes = 265
cores = 8
ram = 13500
rate = 500
timelimit = 18,00
timer = [ 'hpmcount', '-nao', 'prof/hpm' ]
sfc = [ 'xlf95_r' ]
mfc = [ 'mpxlf95_r' ]
_ = [ '-u', '-q64', '-qsuppress=cmpmsg', '-qlanglvl=2003pure', '-qsuffix=f=f90', '-o' ]
g = [ '-g', '-C', '-qflttrap', '-qsigtrap' ] + _
p = [ '-O', '-p' ] + _
O = [ '-O4' ] + _ # -O3 is MUCH slower

