# Kostrov constant rupture velocity test

np = ( 1, 1, 1 )
nt = 400
j, k, l = 61, 61, 21
ihypo = ( j, k, l )
nn = ( 2*j, 2*k, 2*l )
bc1 = ( 10, 10, 10 )
bc2 = ( 10, 10, 10 )
faultnormal = 3
vrup = 3117.6914
rcrit = 1e9
trelax = 0.

io = [
  ( 's0',  'mus',   1e9 ),
  ( 's0',  'mud',   0.  ),
  ( 's0',  'dc',    1e9 ),
  ( 's0',  'co',    0.  ),
  ( 's0',  'tn', -100e6 ),
  ( 's0',  'ts1', -90e6 ),
  ( 'w1', ('sl','svm') ),
  ( 'wi', ('x1','x2','x3'), (1,1,l,0), (-1,-1, l, 0), (1,1,1,1),  1 ),
  ( 'wi', ('v1','v2','v3'), (1,1,1,0), (-1,-1,-1,-1), (1,1,1,20), 1 ),
]

