% Terashake grid

clear all
format compact
field = 'vm';
t = 100:100:3000;
foldcs = 1;
colorexp = 1;
flim = 2;
flim = 1000;
cellfocus = 0;

clf
fg = [ .5 .5 .5 ];
set( gcf, ...
  'Name', 'TS Map', ...
  'NumberTitle', 'off', ...
  'InvertHardcopy', 'off', ...
  'Color', 'k', ...
  'Position', [ 0 720 1280 720 ], ...
  'DefaultAxesColor', 'k', ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultAxesXColor', fg, ...
  'DefaultAxesYColor', fg, ...
  'DefaultAxesZColor', fg, ...
  'DefaultLineColor', fg, ...
  'DefaultLineLineWidth', 1, ...
  'DefaultLineClipping', 'on', ...
  'DefaultTextClipping', 'on', ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 16, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'top', ...
  'DefaultTextColor', 'w' )

% Colormap
if ~foldcs
  cmap = [
    0 0 0 1 1
    1 0 0 0 1
    1 1 0 0 0 ]';
  h = 2 / ( size( cmap, 1 ) - 1 );
  x1 = -1 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = sign( x2 ) .* abs( x2 ) .^ colorexp;
else
  cmap = [
    0 0 0 1 4 4 4
    0 0 4 4 4 0 0
    0 4 4 1 0 0 4 ]' / 4;
  h = 1 / ( size( cmap, 1 ) - 1 );
  x1 = 0 : h : 1;
  x2 = -1 : .0005 : 1;
  x2 = abs( x2 ) .^ colorexp;
end
colormap( interp1( x1, cmap, x2 ) );

% Legend
cwd = pwd;
srcdir
cd data
axes( 'Units', 'Pixels', 'Position', [ 0 0 1280 80 ] )
plot( [ 0 600 ], [ 37.5 37.5 ], 'Clipping', 'off' )
axis( [ 0 600 0 37.5 ] )
axis off
hold on
plot( 140 + [ -50 -50 nan -50 50 nan 50 50 ], 26 + [ -1 1 nan 0 0 nan -1 1 ], 'w', 'LineWidth', 2 )
text( 140, 22, '100km' );
text( 240, 22, '0' );
text( 320, 22, '|V|' );
text( 400, 22, [ num2str( flim ) 'm/s' ] );
imagesc( 320 + [ -80 80 ] , 26 + [ -.33 .33 ], 0:.001:1 )
caxis( [ -1 1 ] )
sio = imread( 'sio.png' );
igpp = imread( 'igpp.png' );
sdsu = imread( 'sdsu.png' );
image( 460 - [ 14   4 ], [ 24 14 ], sio )
image( 512 - [ 19   4 ], [ 24 14 ], igpp )
image( 560 - [ 10.2 4 ], [ 24 14 ], sdsu )
text( 460, 22, 'SIO',  'Hor', 'left' )
text( 512, 22, 'IGPP', 'Hor', 'left' )
text( 560, 22, 'SDSU', 'Hor', 'left' )
htime = text( 15, 22, 'Time = 0s', 'Hor', 'left' );

% Map
axes( 'Units', 'Pixels', 'Position', [ 0 80 1280 640 ] )
sites = {
   82188 188340 129 'bottom' 'right' 'Bakersfield'
   99691  67008  21 'bottom' 'right' 'Santa Barbara'
  191871 180946 714 'bottom' 'right' 'Lancaster'
  229657 119310 107 'bottom' 'right' 'Los Angeles'
  256108 263112 648 'bottom' 'right' 'Barstow'
  263052 216515 831 'bottom' 'right' 'Victorville'
  286666 111230  15 'bottom' 'left'  'Irvine'
  293537 180173 327 'top'    'left'  'San Bernardino'
  296996 160683 261 'top'    'left'  'Riverside'
  366020 200821 140 'top'    'left'  'Palm Springs'
  402013  69548  23 'bottom' 'left'  'San Diego'
  501570  31135  24 'bottom' 'left'  'Ensenada'
  526989 167029   1 'top'    'left'  'Mexicali'
  581530 224874  40 'bottom' 'right' 'Yuma'
};
x = [ sites{:,1} ];
y = [ sites{:,2} ];
z = [ sites{:,3} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
plot3( x, y, z+1000, 'ow', 'MarkerSize', 8, 'MarkerFaceColor', fg, 'MarkerEdgeColor', 'k', 'LineWidth', 2 );
hold on
for i = 1:length(x)
  dy = 2000;
  if strcmp( ver{i}, 'top' ), dy = -3000; end
  text( x(i), y(i)+dy, z(i)+1000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Color', fg );
end
[ x, y, z ] = textread( 'fault.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z, '--', 'LineW', 3 )
[ x, y, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z )
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot3( x, y, z )
view( 0, 90 )
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
axis off

% Surface
cd( cwd )
meta
i1 = [  1  1 -1 ];
i2 = [ -1 -1 -1 ];
[ msg, x ] = read4d( 'x', [ i1 0 ], [ i2 0 ] );
if msg, error( msg ), end
z = x(:,:,:,3);
if ~cellfocus
  z(1:end-1,1:end-1) = .25 * ( ...
    z(1:end-1,1:end-1) + z(2:end,1:end-1) + ...
    z(1:end-1,2:end)   + z(2:end,2:end) );
end
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3)-1000, z );
set( hsurf, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  1, ...
  'DiffuseStrength',  1, ...
  'SpecularColorReflectance', 1, ...
  'SpecularStrength', .3, ...
  'SpecularExponent', .5, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
caxis( 4000 * [ -1 1 ] )
hlit = light( 'Position', [ -300000 150000 0000 ] );
drawnow

% Data
caxis( flim * [ -1 1 ] )
for it = t
  [ msg, s ] = read4d( field, [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
  set( hsurf, 'CData', s )
  drawnow
end

