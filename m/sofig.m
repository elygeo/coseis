% ShakeOut base map

clear all

render = 1;
render = 0;
runs = {
  'CMU/PSC'   'overlay.cmu.png'
  'SDSU/SDSC' 'overlay.sdsu.png'
  'URS/USC'   'overlay.urs.png'
};
cs = 'b00';
ce = .2;
as = 'wk1';
ae = .5;
atran = [ 1 -1 ];
flim = [ .04 2 ]; alim = [ .02 .03 ];
inches = [ 2 4.3 ];
ppi = 150;
dpi = 600; aa = 1;
fg = [ 0 0 0 ];
bg = [ 1 1 1 ];

% Setup
clf
drawnow
colorscheme( cs, ce )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'Position', [ pos(1:2) inches * ppi ], ...
  'PaperPosition', [ 0 0 inches ], ...
  'Color', 'w', ...
  'DefaultTextColor', fg, ...
  'DefaultTextFontSize', 8, ...
  'DefaultLineLinewidth', .5, ...
  'DefaultLineMarkerEdgeColor', bg, ...
  'DefaultLineMarkerFaceColor', fg, ...
  'DefaultAxesColorOrder', fg, ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
y = .5 * inches(2) / inches(1);
y0 = .4 * ( 1 - y );
haxes = axes( 'Position', [ .01 y0 .98 y ] );
hold on
axis equal
axis( 1000 * [ 0 300 0 600 -80 80 ] )
axis ij
box on
set( gca, 'XTick', [], 'YTick', [] )
if ~render, return, end

% Basemap
clear x
n = [ 960 780 ];
fid = fopen( 'topo2.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo1.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
x = upsamp( x );
hmap = surf( x(:,:,1), x(:,:,2), x(:,:,3) - 4000 );
set( hmap, ...
  'EdgeColor', 'none', ...
  'FaceColor', [ .85 .85 .85 ], ...
  'AmbientStrength',  .6, ...
  'DiffuseStrength',  .5, ...
  'SpecularStrength', .5, ...
  'SpecularExponent', 5, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
hmap(end+1) = camlight;
x = 1000 * [ 0 300 300 0 0 ];
y = 1000 * [ 0 0 600 600 0 ];
set( plot( x, y ), 'Clipping', 'off' )
[ y, x, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' ); hmap(end+1) = plot( x, y, 'LineWidth', .1, 'Color', [ .7 .7 .7 ] );
snap( 'basemap.png', dpi, aa );
delete( hmap )
hmap = [];

% Overlay
[ y, x, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' ); hmap(end+1) = plot( x, y, '--', 'LineWidth', 0.75 );
[ y, x, z ] = textread( 'borders.xyz',  '%n%n%n%*[^\n]' ); hmap(end+1) = plot( x, y );
[ y, x, z ] = textread( 'coast.xyz',    '%n%n%n%*[^\n]' ); hmap(end+1) = plot( x, y );
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
  501570  31135  24 'top' 'left'   'Ensenada'
  526989 167029   1 'bottom'    'left'   'Mexicali'
  581530 224874  40 'bottom' 'center' 'Yuma'
};
x = [ sites{:,2} ];
y = [ sites{:,1} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
plot( x, y, 'o', 'MarkerSize', 2.5, 'LineWidth', .65 );
h = [];
for i = 1:length(x)
  dy = -1600;
  if strcmp( ver{i}, 'top' ), dy = 1600; end
  h(end+1) = text( x(i), y(i)+dy, 10, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end
h = pmb( h, 1500, 1500 );
set( h, 'Color', bg );

% Legend
xl = 300;
yl = xl * inches(2) / inches(1);
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
htitle = text( 150, yl-1, 'Title', 'Hor', 'center', 'Ver', 'top' );
x = 200 + [ -75 75 ];
y = 26 + [ -3 3 ];
caxis( flim )
colorscale( '1', x, y, [ 0 2 ], 'b', '0', '2 m/s' )
hold on
axis( [ .01 xl .98 yl ] )
axis off

% Save overlays
for i = 1:size( runs, 1 )
  set( htitle, 'String', runs{i,1} )
  colorscheme( cs, ce )
  caxis( haxes(2), flim )
  img = snap( '', dpi, aa );
  colorscheme( as, ae )
  caxis( haxes(2), alim )
  alpha = snap( '', dpi, aa );
  alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
  imwrite( uint8( img ), runs{i,2}, 'Alpha', alpha, ...
    'XResolution', dpi / 0.0254, ...
    'YResolution', dpi / 0.0254, ...
    'ResolutionUnit', 'meter' )
end

