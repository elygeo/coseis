%------------------------------------------------------------------------------%

clear all
defaults
nt = 120;
bc = [ 0 1 0   0 1 0 ]; grid = 'slant';
bc = [ 1 1 1   1 1 1 ]; grid = 'constant';
n = [ 40 40 40 ]; msrcnodealign = 0;
n = [ 11 11 11 ]; msrcnodealign = 1;
n = [ 61 41 61 ]; msrcnodealign = 1;
n = [ 41 41 41 ]; msrcnodealign = 1;
msrcradius = 1.5 * h;
viscosity = [ .3 .3 ];
viscosity = [ 0 .3 ];
srctimefcn = 'brune';
srctimefcn = 'sbrune';
moment = 1e16 * [ 1 1 1   0 0 0 ];
npml = 0;
npml = 10;
plotstyle = 'slice';
nrmdim = 0;
out = { 'v' 1    1  1  1    -1  0  0 };

setup

