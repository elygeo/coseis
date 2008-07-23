% ShakeOut movie

clear all
xzone = 2;  fzone = 1;  squared = 0; % ShakeOut
vscale = 1;
itoff = 0;
meta
its = 900;
bg = 'k'; fg = 'w'; clk = 'g'; atran = [ 0  1 ]; its = 300:300:nt-itoff;
bg = 'k'; fg = 'w'; clk = 'g'; atran = [ 0  1 ]; its = 0:2:nt-itoff;
bg = 'w'; fg = 'k'; clk = 'k'; atran = [ 1 -1 ]; its = 300:300:nt-itoff;

theta = 40;
zoom = 4.70; mapalpha = .7;
zoom = 9.00; mapalpha = 1;
zoom = 5.72; mapalpha = .7;
zoom = 6.00; mapalpha = .7;
flim = [ .08   2 ];
alim = [ .035 .065 ];
cslim = [ 0.05 2 ];
shadow = [ .1 .1 .1 ];
ms = [ bg 'earth' ];
cs = [ bg 'hot' ];
as = [ bg fg '1' ]; 
ce = .5;
ae = 1;
inches = [ 9.6 5.4 ];
dpi = 300;
ppi = 100;

% Setup
if ~exist( 'tmp', 'dir' ), mkdir tmp, end
clf
drawnow
colorscheme( ms, .4 )
pos = get( gcf, 'Position' );
set( 0, 'ScreenPixelsPerInch', ppi )
set( gcf, ...
  'Position', [ pos(1:2) inches * ppi ], ...
  'PaperPosition', [ 0 0 inches ], ...
  'DefaultAxesColor', 'none', ...
  'DefaultTextFontSize', 10, ...
  'DefaultTextFontWeight', 'bold', ...
  'DefaultTextHorizontalAlignment', 'center', ...
  'DefaultTextVerticalAlignment', 'middle' )
haxes(2) = axes( 'Position', [ 0 0 1 1 ] );
axis off
hold on
axis( 1000 * [ 0 inches(1)/inches(2) 0 1 ] )
haxes(1) = axes( 'Position', [ 0 0 1 1 ] );
axis off
hold on
axis equal
axis( 1000 * [ 0 600 0 300 -80 10 ] )
campos( [ 291 167 3000 ] * 1000 )
camtarget( [ 291 167 0 ] * 1000 )
camva( zoom )
c = cos( theta / 180 * pi );
s = sin( theta / 180 * pi );
camup( [ -s c 0 ] )

% Basemap
file = 'tmp/basemap.png';
if ~exist( file, 'file' )
disp( file )
n = [ 960 780 ];
clear x
fid = fopen( 'topo1.f32', 'r' ); x(:,:,1) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo2.f32', 'r' ); x(:,:,2) = fread( fid, n, 'float32' ); fclose( fid );
fid = fopen( 'topo3.f32', 'r' ); x(:,:,3) = fread( fid, n, 'float32' ); fclose( fid );
x = upsamp( x );
c = x(:,:,3);
c(x(:,:,2)>102000) = max( 10., c(x(:,:,2)>102000) );
c = .25 * ...
  ( c(1:end-1,1:end-1) + c(2:end,2:end) ...
  + c(1:end-1,2:end) + c(2:end,1:end-1) );
h = surf( x(:,:,1), x(:,:,2), x(:,:,3) - 4000, c );
clear x c
[ x, y, z ] = textread( 'salton.xyz', '%n%n%n%*[^\n]' );
z(:) = -1;
h(end+1) = patch( x, y, z - 4000, z );
set( h, ...
  'Clipping', 'off', ...
  'EdgeColor', 'none', ...
  'FaceColor', 'flat', ...
  'AmbientStrength',  0.5, ...
  'DiffuseStrength',  0.5, ...
  'SpecularStrength', 0.5, ...
  'SpecularExponent', 3, ...
  'SpecularColorReflectance', 1, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
camlight( 'infinite' )
caxis( 4000 * [ -1 1 ] )
[ x, y, z ] = textread( 'ca_roads.xyz', '%n%n%n%*[^\n]' );
plot( x, y, 'LineWidth', .2, 'Color', [ .6 .6 .6 ] );
[ x, y, z ] = textread( 'borders.xyz', '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ x, y, z ] = textread( 'coast.xyz',   '%n%n%n%*[^\n]' ); plot( x, y, 'Color', shadow );
[ x, y, z ] = textread( 'fault-so.xyz', '%n%n%n%*[^\n]' );
plot( x, y, '-',  'Color', shadow,  'LineWidth', 2.5 );
plot( x, y, '--', 'Color', 'w', 'LineWidth', 1.5 );
img = snap( file, dpi, 1 );
imwrite( uint8( img ), file, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
delete( get( haxes(1), 'Children' ) )
end

% Overlay
file = 'tmp/overlay.png';
if ~exist( file, 'file' )
disp( file )
sites = {
   82188 188340 129 'top'    'center' 'Bakersfield'
   99691  67008  21 'bottom' 'center' 'Santa Barbara'
  152641  77599  16 'bottom' 'center' 'Oxnard'
  191871 180946 714 'bottom' 'center' 'Lancaster'
  229657 119310 107 'bottom' 'right'  'Los Angeles'
  256108 263112 648 'top'    'center' 'Barstow'
  263052 216515 831 'bottom' 'center' 'Victorville'
  268435 120029  47 'top'    'center' 'Anaheim'
  293537 180173 327 'top'    'right'  'San Bernardino'
  351928  97135  18 'bottom' 'center' 'Oceanside'
  366020 200821 140 'top'    'right'  'Palm Springs'
  402013  69548  23 'bottom' 'center' 'San Diego'
  526989 167029   1 'bottom' 'center' 'Mexicali'
};
x = [ sites{:,1} ];
y = [ sites{:,2} ];
ver = sites(:,4);
hor = sites(:,5);
txt = sites(:,6);
hdots = plot( x, y, 'o', 'MarkerSize', 3.6, 'LineWidth', .75 );
htxtf = [];
for i = 1:length(x)
  dy = 1000;
  if strcmp( ver{i}, 'top' ), dy = -600; end
  htxtf(end+1) = text( x(i), y(i)+dy, 10, txt{i}, 'Ver', ver{i}, 'Hor', hor{i} );
end
htxtb = pmb( htxtf, 500, 500 );
axes( haxes(2) )
x = xlim;
y = ylim;

h = text( x(2)-300, y(2)-40, 'SCEC ShakeOut Simulation', 'Ver', 'top', 'Hor', 'center', 'FontWeight', 'normal', 'FontSize', 16 );
h(2) = text( x(2)-300, y(2)-100, 'by R. Graves', 'Ver', 'top', 'Hor', 'center', 'FontWeight', 'normal', 'FontSize', 10 );
htxtb = [ htxtb pmb( h, 2, 2 ) ];
y = ylim; y = y(2) - 170 - [ 0 100 ];
img = imread( 'shakeout.png' );
x = xlim; x = x(2) - 400 + [ -50 50 ] * size(img,2) / size(img,1);
image( x, y, img )
img = imread( 'scec.png' );
x = xlim; x = x(2) - 200 + [ -50 50 ] * size(img,2) / size(img,1);
image( x, y, img )

h = text( 215, 105, 'Ground velocity magnitude' );
htxtb = [ htxtb pmb( h, 2, 2 ) ];
x = 215 + [ -150 150 ];
y = 70 + [ -5 5 ];
[ h1, h2 ] = colorscale( '1', x, y, cslim, 'b', num2str( cslim(1) ), [ num2str( cslim(2) ) ' m/s' ] );
htxtb = [ htxtb pmb( h2, 2, 2 ) ];
caxis( flim )
axis off
colorscheme( as, ae )
caxis( haxes(2), alim )
alpha = snap( file, dpi, 1 );
colorscheme( cs, ce )
set( hdots, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', shadow )
set( htxtf, 'Color', 'w' )
set( htxtb, 'Color', shadow )
caxis( haxes(2), flim )
img = snap( file, dpi, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
imwrite( uint8( img ), file, 'Alpha', alpha, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
delete( get( haxes(1), 'Children' ) )
delete( get( haxes(2), 'Children' ) )
end

% Surface
axes( haxes(1) )
if xzone
  x = read4d( xzone, [ 0 0 -1 0 ] );
  if isempty( x ), error 'no x data found', end
  x = squeeze( x );
else
  [ x, x2 ] = ndgrid( 0:dx:dx*nn(1), 0:dx:dx*nn(2) );
  x(:,:,2) = x2;
  clear x2
end
i1 = [ out{fzone}{4:7} ];
i2 = [ out{fzone}{8:11} ];
node = all( nn(1:2) == i2(1:2) - i1(1:2) + 1 );
if node
  x(end+1,:,:) = x(end,:,:);
  x(:,end+1,:) = x(:,end,:);
  x(2:end-1,:,:) = .5 * ( x(1:end-2,:,:) + x(2:end-1,:,:) );
  x(:,2:end-1,:) = .5 * ( x(:,1:end-2,:) + x(:,2:end-1,:) );
end
hsurf = surf( x(:,:,1), x(:,:,2), x(:,:,2) );
clear x
set( hsurf, ...
  'EdgeColor', 'none', ...
  'AmbientStrength',  0, ...
  'DiffuseStrength',  1.3, ...
  'SpecularStrength', .0, ...
  'EdgeLighting', 'none', ...
  'FaceLighting', 'phong' );
hlit = camlight( 'infinite' );

% Clock
axes( haxes(2) )
hclk = digitalclock( 160, 160, 40, clk );
set( hclk, 'LineWidth', 1.5 )

% Time loop
for it = its
file = sprintf( 'tmp/f%05d.png', it );
if ~exist( file, 'file' ) & ~system( [ 'mkdir ' file '.lock >& /dev/null' ] )
disp( file )
t = it * dt;
digitalclockset( hclk, t )
s = vscale * read4d( fzone, it+itoff );
if isempty( s ), error 'no v data found', end 
if size( s, 5 ) > 1, s = sqrt( sum( s .* s, 5 ) ); end
if squared, s = sqrt( s ); end
z = s ./ flim(2);
z(end+1,:) = z(end,:);
z(:,end+1) = z(:,end);
z(2:end-1,:) = .5 * ( z(1:end-2,:) + z(2:end-1,:) );
z(:,2:end-1) = .5 * ( z(:,1:end-2) + z(:,2:end-1) );
z = sqrt( z );
set( hsurf, 'CData', s )
set( hsurf, 'ZData', 2000 * z - 4000 )
set( hlit, 'Visible', 'off' )
set( hclk, 'Color', fg, 'MarkerFaceColor', fg )
colorscheme( as, ae )
set( gcf, 'Color', mapalpha * [ 1 1 1 ] )
caxis( haxes(1), alim )
alpha = snap( file, dpi, 1 );
alpha = atran(1) + atran(2) / 765 * sum( alpha, 3 );
set( hlit, 'Visible', 'on' )
c = get( hclk(1), 'Tag' );
set( hclk, 'Color', c, 'MarkerFaceColor', c )
colorscheme( cs, ce )
caxis( haxes(1), flim )
img = snap( file, dpi, 1 );
imwrite( uint8( img ), file, 'Alpha', alpha, ...
  'XResolution', dpi / 0.0254, ...
  'YResolution', dpi / 0.0254, ...
  'ResolutionUnit', 'meter' )
system( [ 'rmdir ' file '.lock' ] );
end
end

