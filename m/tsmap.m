% SAF surface movie

clear all
clf
drawnow

bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];

ppi = 72;
zoom = 5.71;
theta = 0;  phi = 40;
theta = 40; phi = 0;
aa = 3; dpi = 72;  scl = 1.0; res = [ 1280  720 ]; % 720p
aa = 3; dpi = 144; scl = 1.0; res = [  750  375 ]; % 1500x750
aa = 3; dpi = 72;  scl = 1.0; res = [  848  480 ]; % 480p
aa = 3; dpi = 72;  scl = 1.0; res = [ 1024  576 ]; % Projector
aa = 3; dpi = 72;  scl = 1.0; res = [  960  540 ]; % 540p
aa = 3; dpi = 144; scl = 1.0; res = [  960  540 ]; % 1080p

%colorscheme( 'kw1' )
colorscheme( 'earth', .4 )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'PaperPositionMode', 'auto', ...
  'Position', [ pos(1:2) res ], ...
  'Color', 'k', ...
  'DefaultTextColor', fg, ...
  'DefaultTextFontWeight', 'bold', ...
  'DefaultTextFontSize', 16*scl, ...
  'DefaultLineLinewidth', .75*scl, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColorOrder', bg, ...
  'DefaultTextHorizontalAlignment', 'left', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes = axes( 'Position', [ 0 0 1 1 ] );

n = [ 960 780 ];
fid = fopen( 'topo1.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo2.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
xx = zeros( [ 2*n-1 3 ] );
xx(1:2:end,1:2:end,:) = x;
xx(1:2:end,2:2:end,:) = .50 * ( x(:,1:end-1,:) + x(:,2:end,:) );
xx(2:2:end,1:2:end,:) = .50 * ( x(1:end-1,:,:) + x(2:end,:,:) );
xx(2:2:end,2:2:end,:) = .25 * ( x(1:end-1,1:end-1,:) + x(2:end,2:end,:) + x(1:end-1,2:end,:) + x(2:end,1:end-1,:) );
x1 = xx(:,:,1);
x2 = xx(:,:,2);
x3 = xx(:,:,3);
clear x xx
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
hmap(end+1) = plot3( x, y, z+2000, '-',  'LineW', 3*scl,   'Color', bg );
hmap(end+1) = plot3( x, y, z+3000, '--', 'LineW', 2*scl, 'Color', fg );
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
hcity = plot3( x, y, z + 4000, 'o', 'MarkerSize', 4*scl );
htxt = [];
for i = 1:length(x)
  dy = 1400;
  if strcmp( ver{i}, 'top' ), dy = -700; end
  htxt(end+1) = text( x(i), y(i)+dy, z(i)+5000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Rot', phi );
end
h = pmb( htxt, 500, 500 );
set( h, 'Color', [ .1 .1 .1 ] );
hcity = [ hcity htxt h ];

camlight;
caxis( 4000 * [ -1 1 ] )
%snap( 'basemap.png', dpi )

