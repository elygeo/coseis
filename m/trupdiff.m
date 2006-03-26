% Rupture time plot

flim = .05;
colorexp = 1;
colorexp = .5;
dirs = { '1a' '1b' '2a' '2b' '3a' '3b' };
xi = [  -15 : .1 : 15  ];
yi = [ -7.5 : .1 : 7.5 ];
v = 0:0.5:7;

figure(1)
clf
set( gcf, 'Name', 'Rupture Time' )
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
axis image;
axis( [ -15 15 -7.5 7.5 ] )
hold on
title( 'Rupture Time' )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )

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

figure(1)
[ c, h ] = contour( xi, yi, t', v );
delete( h );
i = 1;
while i < size( c, 2 )
  nn = c(2,i);
  c(:,i) = NaN;
  i  = i + nn + 1;
end
plot( c(1,:), c(2,:), 'k', 'Linewidth', .2 )

t = ( t0 - t );
tbar = sum( t(:) ) / prod( n )
rms = sqrt( sum( t(:).^2 ) / prod( n ) )
figure
set( gcf, 'Name', 'Rupture Time Difference' )
axes( 'Position', [ .1 .2 .8 .7 ] );
imagesc( [ -15 15 ], [ -7.5 7.5 ], t' )
axis image;
title( [ 'Model ' dirs{ii} ' rupture time error (s), RMS = ' num2str(rms) ] )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
cmap = [
  0 0 0 1 1
  1 0 0 0 1
  1 1 0 0 0 ]';
cmap = [
  0 0 1 1 1
  0 1 1 1 0
  1 1 1 0 0 ]';
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

print( '-depsc2', [ 'trup' dirs{ii} ] )

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
print( '-depsc2', 'trup' )

return

srcdir
cd 'dalguer'
n = [ 301 151 ];
dx = .1;
dt = .008;
fid = fopen( 'DFM01paper' );
t = fscanf( fid,'%g', n )' - 1.5 * dt;
fclose( fid );
x1 = dx * ( 0:n(1)-1 );  x1 = x1 - .5 * x1(end);
x2 = dx * ( 0:n(2)-1 );  x2 = x2 - .5 * x2(end);
[ c, h ] = contour( x1, x2, t, v );
delete( h );
i = 1;
while i < size( c, 2 )
  nn = c(2,i);
  c(:,i) = NaN;
  i = i + nn + 1;
end
plot( c(1,:), c(2,:), 'r', 'Linewidth', .2 )

