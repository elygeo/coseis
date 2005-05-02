%------------------------------------------------------------------------------%
% SETUP

fprintf( 'SORD - Support-Operator Rupture Dynamics\n' )
format short e
format compact

if ~hypocenter, hypocenter = ceil( n / 2 ); end
if nrmdim, n(nrmdim) = n(nrmdim) + 1; end
halo1 = [ 1 1 1 ];
halo2 = [ 1 1 1 ];
ncore = n;
n = n + halo1 + halo2;
hypocenter = hypocenter + halo1;

readcheckpoint = 0;
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( n ) );
fprintf( 'Base memory usage: %d Mb\n', mem )

initialize = 2;
if plotstyle, viz, end
gridgen
matmodel
output
if nrmdim, fault, end
if msrcradius, momentsrc, end
initialize = 1;
it = 0;
itstep = nt;
umax = 0;
vmax = 0;
wmax = 0;

if readcheckpoint, load checkpoint, stepw, end
fprintf( '    Step      V        U        W      Viz/IO   Total\n' )
%j = hypocenter(1);
%k = hypocenter(2);
%l = hypocenter(3);
%u(j,k,l,1) = 1;
%hgy(:) = 1;
%w1(2:end-1,hypocenter(2),2:end-1,1) = 1;
if plotstyle
  viz
  control
  initialize = 0;
else
  initialize = 0;
  step
end

