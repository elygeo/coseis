%------------------------------------------------------------------------------%
% SETUP

fprintf( 'SORD - Support-Operator Rupture Dynamics\n' )
format short e
format compact

np = n(1:3);
nt = n(4);
clear n
if ~hypocenter, hypocenter = ceil( np / 2 ); end
if nrmdim, np(nrmdim) = np(nrmdim) + 1; end
halo = 1;
nm = np + 2 * halo;
hypocenter = hypocenter + halo;
i1pml = halo + 1  + bc(1:3) * npml;
i2pml = halo + np - bc(4:6) * npml;

readcheckpoint = 0;
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( nm ) );
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
uslipmax = 0;
vslipmax = 0;
tnmax = 0;
tsmax = 0;

if readcheckpoint, load checkpoint, wstep, end
fprintf( '    Step      V        U        W      Viz/IO   Total\n' )
if plotstyle
  viz
  control
  initialize = 0;
  output
else
  initialize = 0;
  output
  step
end

