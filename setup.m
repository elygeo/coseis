%------------------------------------------------------------------------------%
% SETUP

disp( 'SORD - Support-Operator Rupture Dynamics' )
format short e
format compact

if ~hypocenter, hypocenter = ceil( n / 2 ); end
if nrmdim, n(nrmdim) = n(nrmdim) + 1; end
halo1 = [ 1 1 1 ];
halo2 = [ 1 1 1 ];
ncore = n;
n = n + halo1 + halo2;
hypocenter = hypocenter + halo1;

if length( locknodes )
  locknodes(downdim,1:3) = 0;
  if n(1) < 5, locknodes([1 4],1:3) = 0; end
  if n(2) < 5, locknodes([2 5],1:3) = 0; end
  if n(3) < 5, locknodes([3 6],1:3) = 0; end
end
for iz = 1:size( locknodes, 1 )
  zone = locknodes(iz,4:9);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  locki(:,:,iz) = [ i1; i2 ];
end

readcheckpoint = 0;
one = 1;
if str2double( version( '-release' ) ) >= 14, one = single( 1 ); end
zero = 0 * one;
mem = whos( 'one' );
mem = round( mem.bytes / 1024 ^ 2 * 21 * prod( n ) );
fprintf( 1, 'Base memory usage: %d Mb\n', mem )

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
if readcheckpoint, load checkpoint, end
disp( ' step   fault    v        s        viz/io  total' )
if plotstyle
  viz
  control
  initialize = 0;
  disp( 'paused' );
else
  initialize = 0;
  step
end

