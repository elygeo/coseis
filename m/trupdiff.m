% Rupture time plot

flim = .01;
colorexp = 2;
dirs = { '1a' };
xi = [  -15 : .1 : 15  ];
yi = [ -7.5 : .1 : 7.5 ];

n = [ length(xi) length(yi) ];
srcdir
cd 'out/0'
[ x, t ] = trupread;
i = x(:,:,1) >= -15000 & x(:,:,1) <= 15000 & ...
    x(:,:,2) >= -7500 & x(:,:,2) <= 7500;
t0 = reshape( t(i), n );
cd '..'

for ii = 1:length( dirs )

cd( dirs{ii} )
[ x, t ] = trupread;
cd '..'
i = x(:,:,1) >= -15000 & x(:,:,1) <= 15000 & ...
    x(:,:,2) >= -7500 & x(:,:,2) <= 7500;
t = reshape( t(i), n );
t = ( t - t0 );
rms(ii) = sum( t(:) .* t(:) )
figure
set( gcf, 'Name', 'Rupture Time Difference' )
axes( 'Position', [ .1 .2 .8 .7 ] );
imagesc( [ -15 15 ], [ -7.5 7.5 ], t' )
axis image;
title( [ 'Model ' dirs{ii} ': \Delta t' ] )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
cmap = [
  0 0 0 1 1
  1 0 0 0 1
  1 1 0 0 0 ]';
h = 2 / ( size( cmap, 1 ) - 1 );
x1 = -1 : h : 1;
x2 = -1 : .005 : 1;
x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
colormap( interp1( x1, cmap, x2 ) );
caxis( flim * [ -1 1 ] )
axes( 'Position', [ .1 .16 .8 .02 ] );
imagesc( flim * [ -1 1 ], [ -1 1 ], 0:.001:1 );
set( gca, 'XTick', flim * [ -1 0 1 ], 'YTick', [], 'TickLength', [ 0 0 ] )

end

