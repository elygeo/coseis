%------------------------------------------------------------------------------%
% KOSTROV

clear all
inputs
endian = textread( 'out/endian', '%c' );
nt   = textread( 'out/timestep', '', 1 )
hdr  = textread( 'out/01/hdr', '%n', 17 );
rho  = material(1);
fd0  = friction(2);
Tn0  = traction(nrmdim);
i    = 1:3; i(nrmdim) = [];
Ts0  = sqrt( sum( traction(i) .^ 2 ) );
miu0 = rho .* vs .* vs;
C    = .81;
dT   = Ts0 - fd0 * Tn0;
fcorner = vp / ( 6 * h );
nn   = 2 * round( 1 / ( fcorner * dt ) );
b    = .5 * ( 1 - cos( 2 * pi * (1:nn-1) / nn ) );  % hanning
a    = sum( b );
t    = ( 1 : nt )' * dt;
fid  = fopen( 'out/01/mesh', 'r', endian );
xg   = fread( fid, inf, 'float32' );
fclose( fid );
ng   = length( xg ) / 3;
xg   = reshape( xg', [ ng 3 ] );
xg   = ( xg(2:end,:) - xg(1:end-1,:) ) .^ 2;
xg   = [ 0; cumsum( sqrt( sum( xg, 2 ) ) ) ];
for it = 1:nt
  file = sprintf( 'out/01/1/%05d', it );
  fid = fopen( file, 'r', endian );
  ug(it,:) = fread( fid, inf, 'float32' );
  fclose( fid );
  file = sprintf( 'out/02/1/%05d', it );
  fid = fopen( file, 'r', endian );
  vg(it,:) = fread( fid, inf, 'float32' );
  fclose( fid );
end
%vg = filter( b, a, vg );

if ~ishandle(3), figure(3), end
set( 0, 'CurrentFigure', 3 )
clf
di = max( 1, round( ng / 6 ) );
for i = di:di:ng
  vk = C * dT / miu0 * vs * t ./ sqrt( t .^ 2 - ( xg(i) / vrup ) .^ 2 ) .* heaviside( t - xg(i) / vrup );
  vk = filter( b, a, vk );
  plot( t, vg(:,i) )
  hold on
  plot( t, vk, ':' )
end
xlabel( 'Time (s)' )
ylabel( 'Slip Velocity (m/s)' )

if ~ishandle(4), figure(4), end
set( 0, 'CurrentFigure', 4 )
clf
imagesc( t, xg, double( vg' ) );
hold on
plot( [ 0 rcrit/vrup t(end) ], [ 0 rcrit rcrit ] );
if nclramp
plot( [ 0 rcrit/vrup t(end) ] + nclramp * dt, [ 0 rcrit rcrit ] );
end
title( 'Slip Velocity (m/s)' )
xlabel( 'Time (s)' )
ylabel( 'Distance (m)' )
axis xy
shading flat
dark = sum( get( gcf, 'DefaultLineColor' ) );
if dark
  cmap = [
   0 .5  2  4  6  8
   0  0  0  8  8  8
   0  0  8  8  0  0
   0  8  8  0  0  8]' / 8;
else
  cmap = [
   0 .5  2  4  6  8
   8  2  2  8  8  4
   8  2  8  8  2  0
   8  8  8  2  2  0]' / 8;
end
clim = [ 0 1 ] * max( vg(:) );
colormap( interp1( cmap(:,1), cmap(:,2:4), cmap(1,1) : ( cmap(end,1) - cmap(1,1) ) / 1000 : cmap(end,1) ) );
set( gca, 'CLim', clim );

