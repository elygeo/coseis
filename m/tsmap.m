% SAF surface movie

clear all
clf
drawnow

bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];

render = 1;
ppi = 72;
zoom = 5.71;
theta = 0;  phi = 40;
theta = 40; phi = 0;
aa = 3; dpi = 72;  scl = 1.0; res = [ 1280 720 ]; % 720p
aa = 3; dpi = 72;  scl = 1.0; res = [  848 480 ]; % 480p
aa = 3; dpi = 72;  scl = 1.0; res = [ 1024 576 ]; % Projector
aa = 3; dpi = 144; scl = 0.8; res = [  750 375 ]; % 1500x750
aa = 3; dpi = 288; scl = 0.7; res = [  750 375 ]; % 3000x1500
aa = 3; dpi = 144; scl = 1.0; res = [  960 540 ]; % 1080p
aa = 3; dpi = 72;  scl = 1.0; res = [  960 540 ]; % 540p

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

x = 6e5 * [ 0 0 1 1 0 -2  3  3 -2 -2 ];
y = 3e5 * [ 0 1 1 0 0 -2 -2  3  3 -2 ];
z = 4e3 * [ 1 1 1 1 1  1  1  1  1  1 ];
hbox = patch( x, y, z, z );
set( hbox, 'FaceColor', 'k', 'FaceLighting', 'none' )
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

hmap = [];
if 1
clear x
n = [ 960 780 ];
fid = fopen( 'topo1.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo2.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
xx = zeros( [ 2*n-1 3 ] );
xx(1:2:end,1:2:end,:) = x;
xx(1:2:end,2:2:end,:) = .50 * ( x(:,1:end-1,:) + x(:,2:end,:) );
xx(2:2:end,1:2:end,:) = .50 * ( x(1:end-1,:,:) + x(2:end,:,:) );
xx(2:2:end,2:2:end,:) = .25 * ( x(1:end-1,1:end-1,:) + x(2:end,2:end,:) + x(1:end-1,2:end,:) + x(2:end,1:end-1,:) );
c = xx(:,:,3);
c(xx(:,:,2)>102000) = max( 10., c(xx(:,:,2)>102000) );
c = .25 * ...
  ( c(1:end-1,1:end-1) + c(2:end,2:end) ...
  + c(1:end-1,2:end) + c(2:end,1:end-1) );
hmap(end+1) = surf( xx(:,:,1), xx(:,:,2), xx(:,:,3) - 4000, c );
clear x xx c
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
hlit = camlight;
caxis( 4000 * [ -1 1 ] )
[ x, y, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z-1000, 'Color', [ .6 .6 .6 ] );
[ x, y, z ] = textread( 'borders.xyz',  '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
[ x, y, z ] = textread( 'coast.xyz',    '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
%[ x, y ] = textread( 'puente-hills.xy',  '%n%n%*[^\n]' ); plot3( x, y, 4000 + zeros( size( x ) ) );
%[ x, y, z ] = textread( 'sosafe.xyz',  '%n%n%n%*[^\n]' );
[ x, y, z ] = textread( 'fault.xyz',    '%n%n%n%*[^\n]' );
hmap(end+1) = plot3( x, y, z+2000, '-',  'LineW', 3*scl,   'Color', bg );
hmap(end+1) = plot3( x, y, z+3000, '--', 'LineW', 2*scl, 'Color', fg );
end 

% Overlay
sites = {
   99691  67008  21 'bottom' 'center' 'Santa Barbara'
  191871 180946 714 'bottom' 'center' 'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  256108 263112 648 'bottom' 'center' 'Barstow'
  263052 216515 831 'bottom' 'center' 'Victorville'
  268435 120029  47 'top'    'center' 'Anaheim'
  293537 180173 327 'top'    'center' 'San Bernardino'
  366020 200821 140 'top'    'right'  'Palm Springs'
  402013  69548  23 'bottom' 'center' 'San Diego'
  526989 167029   1 'bottom' 'center' 'Mexicali'
};
% 278097 115102  36 'top'    'center' 'Santa Ana'
x = [ sites{:,1} ];
y = [ sites{:,2} ];
z = [ sites{:,3} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
hdots = plot3( x, y, z + 4000, 'o', 'MarkerSize', 5*scl );
htxt = [];
for i = 1:length(x)
  dy = 1400;
  if strcmp( ver{i}, 'top' ), dy = -700; end
  htxt(end+1) = text( x(i), y(i)+dy, z(i)+5000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Rot', phi );
end
htxtb = pmb( htxt, 400, 400 );
set( htxtb, 'Color', bg );
hover = [ hdots htxt htxtb ];

% Legened
axes( 'Position', [ 0 0 1 1 ] )
xx = [ 140 260 ];
yy = [ 140 140 ];
rr = 50;
a = pi * ( 0:120 ) / 60;
hclk(3) = plot( xx(1) + rr * sin( a ), yy(1) + rr * cos( a ), 'w-' ); hold on
hclk(4) = plot( xx(2) + rr * sin( a ), yy(2) + rr * cos( a ), 'w-' );
a = pi * ( 0:6 ) / 3;
x = [ 1 .8 nan ]' * rr * sin( a );
y = [ 1 .8 nan ]' * rr * cos( a );
hclk(5) = plot( xx(1) + x(:), yy(1) + y(:), 'w-' );
a = pi * ( 0:60 ) / 30;
x = [ 1 .9 nan ]' * rr * sin( a );
y = [ 1 .9 nan ]' * rr * cos( a );
hclk(6) = plot( xx(2) + x(:), yy(2) + y(:), 'w-' );
a = pi * ( 0:12 ) / 6;
x = [ 1 .8 nan ]' * rr * sin( a );
y = [ 1 .8 nan ]' * rr * cos( a );
hclk(7) = plot( xx(2) + x(:), yy(2) + y(:), 'w-' );
hclk(8) = plot( xx, yy, 'o', 'MarkerSize', 5*scl );
hclk(9) = text( xx(1), yy(1)-20, 'm', 'Hor', 'center', 'Ver', 'middle' );
hclk(10) = text( xx(2), yy(2)-20, 's', 'Hor', 'center', 'Ver', 'middle' );
hclk(1) = plot( xx(1) + [ 0 0 ], yy(1) + rr * [ -.2 1 ], 'w-' );
hclk(2) = plot( xx(2) + [ 0 0 ], yy(2) + rr * [ -.2 1 ], 'w-' );
set( hclk(1:2), 'LineWidth', 1.5*scl )
x = 1000 * res(1) / res(2);
y = 1000;
axis( [ 0 x 0 y ] )
axis off

%return
set( [ hover hclk(1:2) ], 'Visible', 'off' )
basemap = snap( '', dpi*aa, 1 );
imwrite( uint8( basemap ), 'basemap.png' )
set( [ hmap hclk ], 'Visible', 'off' )
set( hover, 'Visible', 'on' )
overlay = snap( '', dpi*aa, 1 );
set( htxtb, 'Color', fg )
set( hdots, 'MarkerEdgeColor', fg )
alpha = snap( '', dpi*aa, 1 );
alpha = alpha(:,:,1);
imwrite( uint8( overlay ), 'overlay.png', 'Alpha', alpha )
set( htxtb, 'Color', bg )
set( hdots, 'MarkerEdgeColor', bg )
set( [ hmap hclk ], 'Visible', 'on' )
clear all

