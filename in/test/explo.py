# Explosion test problem
np = ( 1, 2, 1 )
nn = ( 71, 71, 61 )
dx = 100.
dt = 0.008
nt = 200
nt = 10
io = [
  ( 's0', 'vp',  6000. ),
  ( 's0', 'vs',  3464. ),
  ( 's0', 'rho', 2700. ),
  ( 's0', 'gam',    0. ),
]
hourglass = ( 1., 7. )
faultnormal = 0
rexpand = 1.06
n1expand = (  0,  0,  0 )
n2expand = ( 20, 20, 20 )
moment1 = ( 1e18, 1e18, 1e18 )
moment2 = ( 0, 0, 0 )
tfunc = 'brune'
tsource = 0.1
xhypo = ( 0., 0., 0. )
bc2 = ( 0, 0, 0 )

io += [
  ( 'wx', 'x',    0., 3999., 0. ),
  ( 'wx', 'v',    0., 3999., 0. ),
  ( 'wx', 'x', 2999., 3999., 0. ),
  ( 'wx', 'v', 2999., 3999., 0. ),
  ( 'wx', 'x', 3999., 3999., 0. ),
  ( 'wx', 'v', 3999., 3999., 0. ),
]


if 1:
  fixhypo = -2
  rsource = 50.
  ihypo = ( 1, 1, 1 )
  bc1   = ( 2, 2, 2 )

if 0:
  fixhypo = -1
  rsource = 100.
  ihypo = ( 2, 2, 2 )
  bc1   = ( 1, 1, 1 )

