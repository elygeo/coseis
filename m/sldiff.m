% Final Slip plots

flim = .05;
colorexp = 1;
colorexp = .5;
dirs = { '1a' '1b' '2a' '2b' '3a' '3b' };
dirs = { '1a' '2a' '3a' };
xi = [  -15 : .1 : 15  ];
yi = [ -7.5 : .1 : 7.5 ];
v = 0:0.5:7;

format compact
figure(1)
clf
set( gcf, 'Name', 'Final Slip' )
axes( 'Position', [ .1 .2 .8 .7 ] );
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
axis image;
axis( [ -15 15 -7.5 7.5 ] )
hold on
title( 'Final Slip (m)' )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )

figure(2)
n = [ length(xi) length(yi) ];
srcdir
cd 'out/0'
[ x, t ] = sliceread( 'sl' );
i = x(:,:,1) >= -15000 & x(:,:,1) <= 15000 & ...
    x(:,:,2) >= -7500 & x(:,:,2) <= 7500;
t0 = reshape( t(i), n );
cd '..'

for ii = 1:length( dirs )

model = dirs{ii}
cd( model )
[ x, t ] = sliceread( 'sl' );
cd '..'
i = x(:,:,1) >= -15000 & x(:,:,1) <= 15000 & ...
    x(:,:,2) >= -7500 & x(:,:,2) <= 7500;
t = reshape( t(i), n );

set( 0, 'CurrentFigure', 1 );
[ c, h ] = contour( xi, yi, t', v );
delete( h );
i = 1;
while i < size( c, 2 )
  nn = c(2,i);
  c(:,i) = NaN;
  i  = i + nn + 1;
end
plot( c(1,:), c(2,:), 'k', 'Linewidth', .2 )

t = ( t - t0 );
tbar = sum( t(:) ) / prod( n )
rms = sqrt( sum( t(:).^2 ) / prod( n ) )
set( 0, 'CurrentFigure', 2 );
clf
set( gcf, 'Name', 'Final slip error' )
axes( 'Position', [ .1 .2 .8 .7 ] );
imagesc( [ -15 15 ], [ -7.5 7.5 ], t' )
axis image;
title( [ 'Model ' model ' final slip error (m), average=' num2str(tbar) ', RMS=' num2str(rms) ] )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
cmap = [
  1 1 0 0 0
  1 0 0 0 1
  0 0 0 1 1 ]';
cmap = [
  1 1 1 0 0
  0 1 1 1 0
  0 0 1 1 1 ]';
h = 2 / ( size( cmap, 1 ) - 1 );
x1 = -1 : h : 1;
x2 = -1 : .005 : 1;
x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
colormap( interp1( x1, cmap, x2 ) );
caxis( flim * [ -1 1 ] )
axes( 'Position', [ .1 .16 .8 .02 ] );
imagesc( flim * [ -1 1 ], [ -1 1 ], 0:.001:1 );
set( gca, ...
  'XTick', flim * [ -1 0 1 ], ...
  'YTick', [], ...
  'TickLength', [ 0 0 ] )

print( '-depsc', [ 'sl' model ] )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress sl' model '.eps &' ] );

end

figure(1)
[ c, h ] = contour( xi, yi, t0', v );
delete( h );
i  = 1;
while i < size( c, 2 )
  n  = c(2,i);
  c(:,i) = NaN;
  i  = i + n + 1;
end
plot( c(1,:), c(2,:), 'b', 'Linewidth', .2 )
print( '-depsc', 'sl' )
system( '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress sl.eps &' );

