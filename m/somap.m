% ShakeOut base map

clear all

render = 0;
runs = {
  'CMU/PSC'   'overlay.cmu.png' ''
  'SDSU/SDSC' 'overlay.sdsu.png' 'SCEC ShakeOut Simulations'
  'URS/USC'   'overlay.urs.png' ''
};
runs = { 'CMU/PSC'   'overlay.cmu.png' };
cs = 'hot';
ce = .2;
as = 'wk1';
ae = .5;
atran = [ 1 -1 ];
flim = [ .04   2 ];
alim = [ .02 .03 ];
aa = 3;
dpi = 72;
scl = 1.0;
theta = 90;
res = [ 320 540 ];
ppi = 72;
phi = 0;
zoom = 5.73;
bg = [ .1 .1 .1 ];
fg = [ 1 1 1 ];
flim = [ 0 1 ];
alim = [ 0.04 0.06 ];

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
  'DefaultTextFontSize', scl * 12, ...
  'DefaultLineLinewidth', scl * 0.75, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColorOrder', bg, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes = axes( 'Position', [ 0 0 1 1 ] );

hold on
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
campos( [ 290 150 3000 ] * 1000 )
camtarget( [ 290 150 0 ] * 1000 )
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
xx = upsamp( x );
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
hlit = camlight;
caxis( 4000 * [ -1 1 ] )
[ x, y, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z-1000, 'Color', [ .6 .6 .6 ] );
[ x, y, z ] = textread( 'borders.xyz',  '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
[ x, y, z ] = textread( 'coast.xyz',    '%n%n%n%*[^\n]' ); hmap(end+1) = plot3( x, y, z );
[ x, y, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' );
hmap(end+1) = plot3( x, y, z+2000, '-',  'LineW', 3*scl,   'Color', bg );
hmap(end+1) = plot3( x, y, z+3000, '--', 'LineW', 2*scl, 'Color', fg );
end 

% Overlay
sites = {
   82188 188340 129 'top'    'center' 'Bakersfield'
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
x = [ sites{:,1} ];
y = [ sites{:,2} ];
z = [ sites{:,3} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
hdots = plot3( x, y, z + 4000, 'o', 'MarkerSize', 5*scl );
htxt = [];
for i = 1:length(x)
  dx = -1600;
  if strcmp( ver{i}, 'top' ), dx = 1600; end
  htxt(end+1) = text( x(i)+dx, y(i), z(i)+9000, txt{i}, 'Ver', ver{i}, 'Hor', hor{i}, 'Rot', phi );
end
htxtb = pmb( htxt, 500, 500 );
set( htxtb, 'Color', bg );
hover = [ hdots htxt htxtb ];

% Legened
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
xl = 300;
yl = 600;
%hhud    = patch( [ 0 0 xl xl 0 ], yl-[ 0 31 31 0 0 ], [ 0 0 0 0 0 ] );
hhud = patch( [ 0 0 xl xl 0 ], [ 0 31 31 0 0 ], [ 0 0 0 0 0 ] );
set( hhud, 'FaceColor', 'k' )
htitle = text( 150, yl-1, t1, 'Hor', 'center', 'Ver', 'top', 'FontSize', 20, 'FontWeight', 'normal' );
htitle(2) = text( 112, 7, t2, 'Hor', 'center', 'Ver', 'baseline', 'FontSize', 20, 'FontWeight', 'normal' );
hold on
axis( [ 0 xl 0 yl ] )
hclk = digitalclock( 7, 7, 16 );
x = 235 + [ -50 50 ];
y = 23 + [ -3 3 ];
[ h1, h2 ] = colorscale( '0.525', x, y, [ 0.05 1 ], 'b', '0.05', '1 m/s' );
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
alpha = sum( overlay, 3 );
alpha(1:26*aa,:) = max( .75, alpha(1:26*aa,:) );
alpha([1:aa end-aa+1:end],:) = 1;
alpha(:,[1:aa end-aa+1:end]) = 1;
imwrite( uint8( overlay ), file, 'Alpha', alpha )
set( [ hmap hclk(:)' ], 'Visible', 'on' )
clear all
end

