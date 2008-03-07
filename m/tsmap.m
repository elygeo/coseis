% TeraShake region map

clear all
clf
drawnow

bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];

render = 0;
ppi = 72;
zoom = 5.71;
theta = 0;  phi = 40;
theta = 40; phi = 0;
aa = 3; dpi = 288; scl = 0.7; res = [  750 375 ]; % 3000x1500
aa = 3; dpi = 72;  scl = 1.0; res = [ 1024 576 ]; % Projector
aa = 3; dpi = 72;  scl = 1.0; res = [  960 540 ]; % 540p
aa = 3; dpi = 144; scl = 1.0; res = [  960 540 ]; % 1080p

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
  'DefaultTextHorizontalAlignment', 'center', ...
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
%[ x, y, z ] = textread( 'fault-ph.xy',  '%n%n%n%*[^\n]' );
%[ x, y, z ] = textread( 'fault-ts.xyz', '%n%n%n%*[^\n]' );
[ x, y, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' );
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
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
xx = [ 100 150 185 ];
yy = 100;
xdig = .2*[11 20 nan; 111 120 nan; 0 9 nan; 100 109 nan; 30 110 nan; 20 100 nan; 10 90 nan]';
ydig = .2*[110 190 nan; 110 190 nan; 10 90 nan; 10 90 nan; 200 200 nan; 100 100 nan; 0 0 nan]';
idig = { 6 [ 1 3 5 6 7 ] [ 1 4 ] [ 1 3 ] [ 3 5 7 ] [ 2 3 ] 2 [ 1 3 6 7 ] [] 3 };
for j = 1:3
for i = 1:10
  ii = 1:7;
  ii(idig{i}) = [];
  x = xx(j) + xdig(:,ii);
  y = yy + ydig(:,ii);
  hclk(j,i) = plot( x(:), y(:), 'r-', 'LineWidth', scl*3 );
  hold on
end
end
hcolon = plot( [ 136 138 ], [ 112 128 ], 'rs', 'MarkerSize', scl*3, 'MarkerFace', 'r', 'MarkerEdgeColor', 'none' );
x = 1000 * res(1) / res(2);
y = 1000;
axis( [ 0 x 0 y ] )
axis off

if render
set( [ hover hclk(:)' hcolon ], 'Visible', 'off' )
basemap = snap( '', dpi*aa, 1 );
imwrite( uint8( basemap ), 'basemap.png' )
set( hmap, 'Visible', 'off' )
set( hover, 'Visible', 'on' )
overlay = snap( '', dpi*aa, 1 );
set( htxtb, 'Color', fg )
set( hdots, 'MarkerEdgeColor', fg )
alpha = snap( '', dpi*aa, 1 );
alpha = alpha(:,:,1);
imwrite( uint8( overlay ), 'overlay.png', 'Alpha', alpha )
set( htxtb, 'Color', bg )
set( hdots, 'MarkerEdgeColor', bg )
set( [ hmap hclk(:)' hcolon ], 'Visible', 'on' )
clear all
end

