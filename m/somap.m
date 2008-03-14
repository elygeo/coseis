% TeraShake base map

clear all

bb = 4;
dpi = 144; scl = 1.0; theta = 90; res = [ 320+bb 540 ]; % 1080p
dpi = 72;  scl = 1.0; theta = 90; res = [ 320+bb 540 ]; % 540p
render = 0;
ppi = 72;
phi = 0;
zoom = 5.73;
aa = 1;
bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];

clf
drawnow
colorscheme( 'earth', .4 )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'PaperPositionMode', 'auto', ...
  'Position', [ pos(1:2) res ], ...
  'Color', 'k', ...
  'DefaultTextColor', fg, ...
  'DefaultTextFontWeight', 'bold', ...
  'DefaultTextFontSize', 12*scl, ...
  'DefaultLineLinewidth', .75*scl, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColorOrder', bg, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes = axes( 'Position', [ 0 0 1 1 ] );

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
xx = x;
%xx = upsample( x );
c = xx(:,:,3);
c(xx(:,:,2)>102000) = max( 10., c(xx(:,:,2)>102000) );
c = .25 * ...
  ( c(1:end-1,1:end-1) + c(2:end,2:end) ...
  + c(1:end-1,2:end) + c(2:end,1:end-1) );
hmap(end+1) = surf( xx(:,:,1), xx(:,:,2), xx(:,:,3) - 4000, c );
clear x xx c
[ x, y, z ] = textread( 'salton.xyz', '%n%n%n%*[^\n]' );
z(:) = -1;
hmap(end+1) = patch( x, y, z - 4000, z );
set( hmap, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  .5, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
%set( hmap(end), 'FaceLighting', 'none' )
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
   82188 188340 129 'bottom' 'center' 'Bakersfield'
   99691  67008  21 'bottom' 'center' 'Santa Barbara'
  152641  77599  16 'bottom' 'right'  'Oxnard'
  191871 180946 714 'bottom' 'left'   'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  263052 216515 831 'bottom' 'left'   'Victorville'
  268435 120029  47 'bottom' 'right'  'Anaheim'
  293537 180173 327 'top'    'right'  'San Bernardino'
  366020 200821 140 'bottom' 'right'  'Palm Springs'
  402013  69548  23 'top'    'center' 'San Diego'
  501570  31135  24 'bottom' 'left'   'Ensenada'
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
  if strcmp( ver{i}, 'top' ), dy = -1400; end
  htxt(end+1) = text( x(i), y(i)+dy, z(i)+9000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Rot', phi );
end
htxtb = pmb( htxt, 400, 400 );
set( htxtb, 'Color', bg );
hover = [ hdots htxt htxtb ];

% Legened
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
xl = 300;
yl = 600;
htitle = text( 6, 6, 'ShakeOut', 'Hor', 'left', 'Ver', 'baseline', 'FontSize', 20, 'FontWeight', 'normal' );
hold on
axis( [ 0 xl 0 yl ] )
s =  .08;
xx = 110 + s * [ 0 200 350 ];
yy = 7;
xdig = s*[11 20 nan; 111 120 nan; 0 9 nan; 100 109 nan; 30 110 nan; 20 100 nan; 10 90 nan]';
ydig = s*[110 190 nan; 110 190 nan; 10 90 nan; 10 90 nan; 200 200 nan; 100 100 nan; 0 0 nan]';
idig = { 6 [ 1 3 5 6 7 ] [ 1 4 ] [ 1 3 ] [ 3 5 7 ] [ 2 3 ] 2 [ 1 3 6 7 ] [] 3 };
for j = 1:3
for i = 1:10
  ii = 1:7;
  ii(idig{i}) = [];
  x = xx(j) + xdig(:,ii);
  y = yy + ydig(:,ii);
  hclk(j,i) = plot( x(:), y(:), 'g-', 'LineWidth', scl*s*20 );
  hold on
end
end
hclk(:,11) = plot( xx(1) + s * [ 155 165 ], yy + s * [ 50 150 ], 'gs', 'MarkerSize', scl*3, 'MarkerFace', 'g', 'MarkerEdgeColor', 'none' );
[ h1, h2 ] = colorscale( 'cm/s', 235 + [ -50 50 ], 23 + [ -3 3 ], [ 0.05 1 ], 'b', '5', '100' );
axis off
hover = [ hover htitle h1 h2 ];

if render
set( [ hover hclk(:)' ], 'Visible', 'off' )
basemap = snap( '', dpi*aa, 1 );
imwrite( uint8( basemap ), 'basemap.png' )
set( hmap, 'Visible', 'off' )
set( hover, 'Visible', 'on' )
colorscheme( 'hot', .25 )
overlay = snap( '', dpi*aa, 1 );
alpha = snap( '', dpi*aa, 1 );
alpha = sum( alpha, 3 );
imwrite( uint8( overlay ), 'overlay.png', 'Alpha', alpha )
set( [ hmap hclk(:)' ], 'Visible', 'on' )
clear all
end

