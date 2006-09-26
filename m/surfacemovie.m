% Terashake map plot

clear all
format compact
field = 'vm';
t = 100:100:5000;
t = 3000:100:5000;
t = 5000;
t = 0;
flim = 1;
cellfocus = 0;
hardcopy = 1;

clf
colorscheme
pos = get( gcf, 'Position' );
set( gcf, ...
  'DefaultLineMarkerFaceColor', 'w', ...
  'DefaultLineMarkerEdgeColor', [ .2 .2 .2 ], ...
  'DefaultLineClipping', 'on', ...
  'DefaultTextClipping', 'on', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )

% Legend
cwd = pwd;
srcdir
cd data
%set( gcf, 'Position', [ pos(1:2) 1280 80 ] )
axes( 'Position', [ 0 0 1 1 ] )
htime = text( 15, 20, 'Time = 0s' );
hold on
plot( 150 + [ -50 -50 nan -50 50 nan 50 50 ], 20 + [ -2 2 nan 0 0 nan -2 2 ] )
text( 150, 20, '100km', 'Hor', 'center', 'Background', 'k' );
caxis( flim * [ -1 1 ] )
colorscale( '|V|: ', 'm/s', 325 + [ -50 50 ], [ 18 22 ] )
igpp = imread( 'igpp.png' );
sio  = imread( 'sio.png'  );
sdsu = imread( 'sdsu.png' );
image( 460 - [ 19   4 ], [ 25 15 ], igpp )
image( 513 - [ 14   4 ], [ 25 15 ], sio  )
image( 560 - [ 10.2 4 ], [ 25 15 ], sdsu )
text( 460, 20, 'IGPP' )
text( 513, 20, 'SIO'  )
text( 560, 20, 'SDSU' )
axis( [ 0 600 0 37.5 ] )
axis off
%leg = snap;
%imshow( leg )
delete( gca )

% Map
set( gcf, 'Position', [ pos(1:2) 1280 640 ] )
axes( 'Position', [ 0 0 1 1 ] )
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
plot3( x, y, z+1000, 'ow', 'MarkerSize', 8, 'LineWidth', 2 );
hold on
for i = 1:length(x)
  dy = 2000;
  if strcmp( ver{i}, 'top' ), dy = -3000; end
  text( x(i), y(i)+dy, z(i)+1000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
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
h = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3)-1000 );
set( h, ...
  'FaceColor', [ .2 .2 .2 ], ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .1, ...
  'DiffuseStrength',  .1, ...
  'SpecularColorReflectance', 1, ...
  'SpecularStrength', .25, ...
  'SpecularExponent', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
light( 'Position', [ -300000 150000 100000 ] );
%map = snap;
drawnow
clf

return

% Data
axes( 'Position', [ 0 0 1 1 ] )
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3) );
view( 0, 90 )
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
axis off
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
  %drawnow
  %snap( sprintf( 'tmp/frame%04d.png', it ) )
end

