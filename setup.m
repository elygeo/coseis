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
i1pml = halo1 + 1     + bc(1:3) * npml;
i2pml = halo1 + ncore - bc(4:6) * npml;

readcheckpoint = 0;
one = 1;
%if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
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

if readcheckpoint, load checkpoint, wstep, end
fprintf( '    Step      V        U        W      Viz/IO   Total\n' )
if plotstyle
  viz
  control
  initialize = 0;
else
  initialize = 0;
  step
end

