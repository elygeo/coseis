i1z = [ 1 1 1 ];
i2z = [ 41 41 41 ];
it = 190;

vizfield = 'x'
i1s = [ i1z 0 ];
i2s = [ i2z 0 ];
ic = 0;
get4dsection
x = gg;

vizfield = 'v'
i1s = [ i1z it ];
i2s = [ i2z it ];
ic = 0;
get4dsection
v = gg;

vizfield = 'w'
i1s = [ i1z it ];
i2s = [ i2z it ];
ic = 0;
get4dsection
w = gg;

