% Rupture time plot

flim = .05;
colorexp = 1;
colorexp = .5;
dir0 = 'out/100'; dirs = { '100-1a' '100-2a' '100-3a' };
dir0 = 'out/050'; dirs = { '100-1a' '100-2a' '100-3a' };
xi = [  -15 : .1 : 15  ];
yi = [ -7.5 : .1 : 7.5 ];
v = 0:0.5:7;

format compact
figure(1)
clf
set( gcf, 'Name', 'Rupture Time' )
colorscheme
axes( 'Position', [ .1 .2 .8 .7 ] );
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
axis image;
axis( [ -15 15 -7.5 7.5 ] )
hold on
title( 'Rupture Time' )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )

figure(2)
n = [ length(xi) length(yi) ];
srcdir
cd( dir0 )
t0 = faultread( 'trup' );
cd '..'

for ii = 1:length( dirs )

model = dirs{ii}
cd( model )
t = faultread( 'trup' );
cd '..'

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
set( gcf, 'Name', 'Rupture Time Delay' )
colorscheme
axes( 'Position', [ .1 .2 .8 .7 ] );
imagesc( [ -15 15 ], [ -7.5 7.5 ], t' )
axis image;
title( [ 'Model ' model ' rupture time delay (s), average=' num2str(tbar) ', RMS=' num2str(rms) ] )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )
caxis( flim * [ -1 1 ] )
axes( 'Position', [ .1 .16 .8 .02 ] );
imagesc( flim * [ -1 1 ], [ -1 1 ], 0:.001:1 );
set( gca, ...
  'XTick', flim * [ -1 0 1 ], ...
  'YTick', [], ...
  'TickLength', [ 0 0 ] )

print( '-depsc', [ 'trup' model ] )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress trup' model '.eps &' ] );

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
print( '-depsc', 'trup' )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress trup.eps &' ] );

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

