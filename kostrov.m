%------------------------------------------------------------------------------%
% KOSTROV

clear all
defaults

npml = 0;
npml = 10;
nclramp = 0;
nclramp = 10;
bc = [ 0 0 0   0 0 0 ];
bc = [ 0 1 0   0 1 0 ];
rcrit = 1e10;
friction = [ 1e10 1   1e10 0   1 1 1  -1 -1 -1 ];
traction = [ -100e6 -90e6 0    1 1 1  -1 -1 -1 ];
grid = 'slant';
grid = 'constant';
n = [ 201  41 201 ]; nt = 400; plotstyle = '';
n = [ 101  41 101 ]; nt = 200; plotstyle = 'fault';
n = [  61  41  61 ]; nt = 120; plotstyle = 'fault';
n = [  41  41  41 ]; nt =  90; plotstyle = 'fault';
out = {
  'uslip' 1    0  0  0   -1 -0 -0
  'vslip' 1    0  0  0   -1 -0 -0
  'v'     1    1  1  1   -1 -0 -0
};

setup

