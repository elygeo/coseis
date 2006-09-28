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
  'DefaultLineMarkerEdgeColor', [ .1 .1 .1 ], ...
  'DefaultLineClipping', 'on', ...
  'DefaultTextClipping', 'on', ...
  'DefaultTextFontSize', 14, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )

% Legend
cwd = pwd;
srcdir
cd data
set( gcf, 'Position', [ pos(1:2) 1280 80 ] )
axes( 'Position', [ 0 0 1 1 ] )
text( 15, 24, 'M7.6 Southern San Andreas Senario' );
hold on
text( 15, 14, 'SORD Rupture Dynamics Simulation' );
a = 40;
c = cos( a / 180 * pi );
s = sin( a / 180 * pi );
x = 200 + 5 * [ c -c; s -s ]';
y =  19 + 5 * [ s -s; -c c ]';
z =  [ 0 0; 0 0 ];
plot3( x, y, z )
x = 200 + 9 * [ c -c; s -s ]';
y =  19 + 9 * [ s -s; -c c ]';
h    = text( x(1), y(1), 0, 'E' );
h(2) = text( x(2), y(2), 0, 'W' );
h(3) = text( x(3), y(3), 0, 'S' );
h(4) = text( x(4), y(4), 0, 'N' );
set( h, 'Rotation', a, 'Hor', 'center', 'FontSize', 12 )
caxis( flim * [ -1 1 ] )
colorscale( '', 'm/s', 300 + [ -50 50 ], [ 12 16 ] )
lengthscale( '', 'km', 300 + [ -50 50 ], [ 22 26 ] )
igpp = imread( 'igpp.png' );
sio  = imread( 'sio.png'  );
sdsu = imread( 'sdsu.png' );
scec = imread( 'scec.png'  );
image( 460 + 8 * [ 0 3    ], 19 - 8 * [ -1 1 ], scec )
image( 500 + 8 * [ 0 3    ], 19 - 8 * [ -1 1 ], igpp )
image( 533 + 8 * [ 0 2    ], 19 - 8 * [ -1 1 ], sio  )
image( 560 + 8 * [ 0 1.23 ], 19 - 8 * [ -1 1 ], sdsu )
axis( [ 0 600 0 37.5 ] )
axis off
%leg = snap;
%imshow( leg )
delete( gca )

% Map
set( gcf, 'Position', [ pos(1:2) 1280 640 ] )
axes( 'Position', [ 0 0 1 1 ] )
sites = {
   82188 188340 129 'bottom' 'center' 'Bakersfield'
   99691  67008  21 'bottom' 'right' 'Santa Barbara'
  152641  77599  16 'bottom' 'center' 'Oxnard'
  191871 180946 714 'bottom' 'center' 'Lancaster'
  229657 119310 107 'bottom' 'center' 'Los Angeles'
  253599  98027   7 'bottom' 'center'  'Long Beach'
  256108 263112 648 'bottom' 'center' 'Barstow'
  263052 216515 831 'bottom' 'center' 'Victorville'
  278097 115102  36 'bottom'    'center'  'Santa Ana'
  293537 180173 327 'top'    'center'  'San Bernardino'
  296996 160683 261 'top'    'center'  'Riverside'
  351928  97135  18 'bottom' 'left'  'Oceanside'
  366020 200821 140 'top'    'center'  'Palm Springs'
  403002 210421 -18 'top'    'center'  'Coachella'
  402013  69548  23 'bottom' 'center'  'San Diego'
  501570  31135  24 'bottom' 'center'  'Ensenada'
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
  dy = 3000;
  if strcmp( ver{i}, 'top' ), dy = -3000; end
  text( x(i), y(i)+dy, z(i)+1000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end
[ x, y, z ] = textread( 'fault.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z, '--', 'LineW', 3 )
[ x, y, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot3( x, y, z )
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot3( x, y, z )
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot3( x, y, z )
text( 3000, 3000, 0, 'GPE', 'Hor', 'left', 'Ver', 'bottom', 'FontSize', 8 )
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
ihypo = ihypo - i1(1:3) + 1;
x(:,ihypo(2),:,:) = [];
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3)-1000 );
set( hsurf, ...
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

% Data
axes( 'Position', [ 0 0 1 1 ] )
hsurf = surf( x(:,:,:,1), x(:,:,:,2), x(:,:,:,3) );
hold on
htime = text( 15, 20, 'Time = 0s' );
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
  %img = snap( sprintf( 'tmp/frame%04d.png', it ) )
end

return

img = single( img );
w = rgb2gray( img ) ./ 255;
w = .5 * ( 1 - w ) .^ 2;
for i = 1:3
  img(:,:,i) = img(:,:,i) + w .* basemap(:,:,i);
end 
img = uint8( img );
img = [ img; leg ];
img([1 end],:,:) = 32;
img(:,[1 end],:) = 32;
clf
imshow( img );
imwrite( img, sprintf( 'tmp/frame%04d.png', it ) )

