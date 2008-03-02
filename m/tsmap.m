% SAF surface movie

clear all
clf
drawnow

bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];
res = [ 1024 576 ];
res = [ 800 755 ];
scl = 1.6;

theta = 0;  phi = 40;
theta = 40; phi = 0;
zoom = 5.71;
dpi = 72;  res = [ 1024 576 ]; scl = 1.6; % Projector
dpi = 72;  res = [ 1280 720 ]; scl = 2.2; % 720p
dpi = 144; res = [  750 375 ]; scl = 1.5; % Amit
dpi = 72;  res = [  848 480 ]; scl = 1.5; % 480p
dpi = 72;  res = [  960 540 ]; scl = 2.0; % 540p
dpi = 144; res = [  960 540 ]; scl = 2.0; % 1080p
ppi = 72;
aa = 3;

colorscheme( 'earth', .4 )
%colorscheme( 'kw1' )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'PaperPositionMode', 'auto', ...
  'Position', [ pos(1:2) res ], ...
  'Color', 'k', ...
  'DefaultTextColor', fg, ...
  'DefaultTextFontWeight', 'bold', ...
  'DefaultTextFontSize', 9 * scl, ...
  'DefaultLineLinewidth', .5 * scl, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColorOrder', bg, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes = axes( 'Position', [ 0 0 1 1 ] );

fid = fopen( 'topo1.f32', 'r' ); x1 = fread( fid, [ 960 780 ], 'float32' ); fclose( fid );
fid = fopen( 'topo2.f32', 'r' ); x2 = fread( fid, [ 960 780 ], 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x3 = fread( fid, [ 960 780 ], 'float32' ); fclose( fid );

c = max( x3, 10. );
c( x2 < 102000 ) = x3( x2 < 102000 );
hmap = surf( x1, x2, x3 - 4000, c );
[ x, y, z ] = textread( 'salton.xyz',   '%n%n%n%*[^\n]' );
c = -1 * ones( size( z ) );
hmap(end+1) = patch( x, y, z - 3990, c );
set( hmap, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .5, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
hold on
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
campos( [ 300 150 3000 ] * 1000 )
camtarget( [ 300 150 0 ] * 1000 )
camva( zoom )
c = cos( theta / 180 * pi );
s = sin( theta / 180 * pi );
camup( [ -s c 0 ] )
axis off
[ x, y, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z-1000, 'Color', [ .6 .6 .6 ] );
[ x, y, z ] = textread( 'borders.xyz',  '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
[ x, y, z ] = textread( 'coast.xyz',    '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
%[ x, y ] = textread( 'puente-hills.xy',  '%n%n%*[^\n]' ); plot3( x, y, 4000 + zeros( size( x ) ) );
%[ x, y, z ] = textread( 'sosafe.xyz',  '%n%n%n%*[^\n]' );
[ x, y, z ] = textread( 'fault.xyz',    '%n%n%n%*[^\n]' );
hmap(end+1) = plot3( x, y, z+2000, '-',  'LineW', 2.2*scl, 'Color', bg );
hmap(end+1) = plot3( x, y, z+3000, '--', 'LineW', 1.5*scl, 'Color', fg );
x = 6e5 * [ 0 0 1 1 0 -2  3  3 -2 -2 ];
y = 3e5 * [ 0 1 1 0 0 -2 -2  3  3 -2 ];
z = 4e3 * [ 1 1 1 1 1  1  1  1  1  1 ];
hmap(end+1) = patch( x, y, z, z );
set( hmap(end), 'FaceColor', 'k', 'FaceLighting', 'none' )
sites = {
   99691  67008  21 'bottom' 'center' 'Santa Barbara'
  191871 180946 714 'bottom' 'center' 'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  256108 263112 648 'bottom' 'center' 'Barstow'
  263052 216515 831 'bottom' 'center' 'Victorville'
  278097 115102  36 'top'    'center' 'Santa Ana'
  293537 180173 327 'top'    'center' 'San Bernardino'
  366020 200821 140 'top'    'right'  'Palm Springs'
  402013  69548  23 'bottom' 'center' 'San Diego'
  526989 167029   1 'bottom' 'center' 'Mexicali'
};
x = [ sites{:,1} ];
y = [ sites{:,2} ];
z = [ sites{:,3} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
hcity = plot3( x, y, z + 4000, 'o', 'MarkerSize', 3*scl, 'LineWidth', .6*scl );
htxt = [];
for i = 1:length(x)
  dy = 1000;
  if strcmp( ver{i}, 'top' ), dy = -1000; end
  htxt(end+1) = text( x(i), y(i)+dy, z(i)+5000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Rot', phi );
end
h = pmb( htxt, 400, 400 );
set( h, 'Color', [ .1 .1 .1 ] );
hcity = [ hcity htxt h ];

camlight;
caxis( 4000 * [ -1 1 ] )
%snap( 'basemap.png', dpi )

