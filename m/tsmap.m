% Terashake map plot

clear all
format compact
field = 'vm';
t = 1000:1000:5000;
flim = 1;
cellfocus = 0;

clf
pos = get( gcf, 'Position' );
set( gcf, ...
  'Color', 'w', ...
  'Position', [ pos(1:2) 1280 720 ], ...
  'DefaultAxesColorOrder', [ 0 0 0 ], ...
  'DefaultLineLineWidth', 1, ...
  'DefaultTextFontName', 'Helvetica', ...
  'DefaultTextFontSize', 16, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'top' )
setcolormap( 'folded', 'light' )

% Legend
cwd = pwd;
srcdir
cd data
axes( 'Units', 'Pixels', 'Position', [ 0 0 1280 80 ] )
plot( [ 0 600 ], [ 37.5 37.5 ], 'Clipping', 'off' )
axis( [ 0 600 0 37.5 ] )
axis off
hold on
plot( 200 + [ -50 -50 nan -50 50 nan 50 50 ], 26 + [ -1 1 nan 0 0 nan -1 1 ], 'k', 'LineWidth', 2 )
text( 200, 22, '100km' );
text( 320, 22, '0' );
text( 420, 22, '|V|' );
text( 520, 22, [ num2str( flim ) 'm/s' ] );
imagesc( 420 + [ -100 100 ] , 26 + [ -.33 .33 ], 0:.001:1 )
caxis( [ -1 1 ] )
htime = text( 50, 22, 'Time = 0s', 'Hor', 'left' );

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
plot3( x, y, z+1000, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', [.9 .9 .9], 'LineWidth', 2 );
hold on
for i = 1:length(x)
  dy = 2000;
  if strcmp( ver{i}, 'top' ), dy = -3000; end
  text( x(i), y(i)+dy, z(i)+1000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Color', 'k' );
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
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3)-1000 );
set( hsurf, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .8, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularColorReflectance', 0, ...
  'SpecularExponent', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
lighting phong
hlit = light( 'Position', 1000 * [ -300 150 50 ] );

% Data
caxis( flim * [ -1 1 ] )
for it = t
  it
  [ msg, s ] = read4d( field, [ i1 it ], [ i2 it ] );
  if msg, error( msg ), end
  if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
  if ~cellfocus
    s(1:end-1,1:end-1) = .25 * ( ...
      s(1:end-1,1:end-1) + s(2:end,1:end-1) + ...
      s(1:end-1,2:end)   + s(2:end,2:end) );
  end
  set( hsurf, 'CData', s )
  set( htime, 'String', sprintf( 'Time = %.1fs', it * dt ) )
  snap( sprintf( 'map%04d.png', it ) )
end

